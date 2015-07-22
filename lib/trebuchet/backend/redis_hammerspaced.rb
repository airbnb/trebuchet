require 'trebuchet/backend/redis'
require 'json'

class Trebuchet::Backend::RedisHammerspaced < Trebuchet::Backend::Redis

  # This class will rely on a cron job to sync all trebuchet features
  # to local hammerspace thus this class never directly updates hammerspace
  # We also cache in memory the features and rely on before_filter
  # to lazily invalidate local cache

  attr_accessor :namespace

  def initialize(*args)
    # args.first must be a hash
    super(*args)
    @hammerspace = args.first[:hammerspace]
  end

  def get_strategy(feature_name)
    if cached_strategies.has_key?(feature_name)
      # use cached if available (even if value is nil)
      cached_strategies[feature_name]
    else
      # call to hammerspace
      cache_strategy feature_name, get_strategy_hammerspace(feature_name)
    end
  end

  def get_strategy_hammerspace(feature_name)
    # Read from hammerspace
    h = @hammerspace[feature_key(feature_name)]
    return nil unless h
    # h will be a string, we need to convert it back to Hash
    begin
      h = JSON.load(h)
    rescue
      return nil
    end
    unpack_strategy_hammerspace(h)
  end

  def unpack_strategy_hammerspace(options)
    # We don't need to further convert values
    # because it's already taken care of
    # by the refresh cron job
    # assumption here is that v will be an array and we
    # are using the first element for now
    # This makes the format compatible with redis backend
    return nil unless options.is_a?(Hash)
    [].tap do |a|
      options.each do |k, v|
        key = k.to_sym
        a << key
        a << v.first
      end
    end
  end

  def get_feature_names
    # Read from hammerspace
    return [] unless @hammerspace.has_key?(feature_names_key)
    JSON.load(@hammerspace[feature_names_key])
  end

  def append_strategy(feature_name, strategy, options = nil)
    # though we can't clear the strategy for all active instances
    # this will clear the cache in the console environment to show current settings
    clear_cached_strategies
    super(feature_name, strategy, options)
  end

  def cache_strategy(feature_name, strategy)
    cached_strategies[feature_name] = strategy
  end

  def cached_strategies
    @cached_strategies ||= Hash.new
  end

  def clear_cached_strategies
    @cached_strategies = nil
  end

  def refresh
    # We close and reopen hammerspace to see if we need to invalidate local cache
    uid = @hammerspace.uid
    @hammerspace.close
    if @hammerspace.uid != uid
      clear_cached_strategies
    end
  end

  def update_hammerspace(forced = false)
    last_updated = get_sentinel

    return if !forced && last_updated == @hammerspace[sentinel_key]

    feature_names = @redis.smembers(feature_names_key)

    features = @redis.pipelined do
      feature_names.each do |feature_name|
        @redis.hgetall(feature_key(feature_name))
      end
    end

    hash = generate_hammerspace_hash(feature_names, features, last_updated)

    @hammerspace.replace(hash)
    @hammerspace.close
    clear_cached_strategies
  end

  # feature_names is an array of strings
  # features is an array of strategies
  # Each strategy is of form ["<key1>", "<value1>", "<key2>", "<value2>"...]
  # We need to decode the values because they are in string form (not actual hash)
  def generate_hammerspace_hash(feature_names, features, last_updated)
    hash = {
      sentinel_key => last_updated,
      feature_names_key => feature_names.to_json,
    }

    feature_names.zip(features) do |feature_name, feature|
      h = {}
      feature.each_slice(2) {|k,v| h[k]=JSON.load(v)}
      hash[feature_key(feature_name)] = h.to_json
    end
    hash
  end

end
