require 'redis' unless defined?(Redis)
require 'json'

class Trebuchet::Backend::Redis
  
  attr_accessor :namespace
  
  def initialize(*args)
    @namespace = 'trebuchet/'
    begin
      if args.first.is_a?(Hash) && (client = args.first[:client]) && (client.is_a?(Redis) || client.is_a?(MockRedis))
        # ignore other args and use provided Redis connection
        @options = args.first
        @redis = args.first[:client]
      else
        @redis = Redis.new(*args)
      end
      unless @options && @options[:skip_check]
        # raise error if not connectedUncaught ReferenceError: google is not defined 
        @redis.exists(feature_names_key) # @redis.info is slow and @redis.client.connected? is NOT reliable
      end
    rescue Exception => e
      raise Trebuchet::BackendInitializationError, e.message
    end
  end

  def get_strategy(feature_name)
    return nil unless h = @redis.hgetall(feature_key(feature_name))
    unpack_strategy(h)
  end
  
  def unpack_strategy(options)
    return nil unless options.is_a?(Hash)
    [].tap do |a|
      options.each do |k, v|
        begin
          key = k.to_sym
          value = JSON.load(v).first # unpack from array
          a << key
          a << value
        rescue
          # if it can't parse the JSON, skip it
        end
      end
    end
  end

  def set_strategy(feature_name, strategy, options = nil)
    remove_strategy(feature_name)
    append_strategy(feature_name, strategy, options)
  end

  def append_strategy(feature_name, strategy, options = nil)
    @redis.srem(archived_feature_names_key, feature_name)
    @redis.hset(feature_key(feature_name), strategy, [options].to_json) # have to put options in container for json
    @redis.sadd(feature_names_key, feature_name)
    store_history(feature_name)
  end
  
  def remove_strategy(feature_name)
    @redis.del(feature_key(feature_name))
  end
  
  def get_feature_names
    @redis.smembers(feature_names_key)
  end
  
  def get_archived_feature_names
    @redis.smembers(archived_feature_names_key)
  end
  
  def remove_feature(feature_name)
    @redis.del(feature_key(feature_name))
    @redis.srem(feature_names_key, feature_name)
    @redis.sadd(archived_feature_names_key, feature_name)
  end
  
  def store_history(feature_name)
    timestamp = Time.now.to_i
    h = @redis.hgetall(feature_key(feature_name))
    @redis.hmset(feature_history_key(feature_name, timestamp), *h.to_a.flatten)
    @redis.sadd(feature_history_key(feature_name), timestamp) # subtle
  end
  
  def get_history(feature_name)
    [].tap do |history|
      @redis.smembers(feature_history_key(feature_name)).sort.each do |timestamp|
        h = @redis.hgetall(feature_history_key(feature_name, timestamp))
        history << [timestamp.to_i, unpack_strategy(h)]
      end
    end
  end

  def get_all_history(include_archived = false)
    history = []

    features = @redis.smembers(feature_names_key)
    features += @redis.smembers(archived_feature_names_key) if include_archived

    result = @redis.pipelined do
      features.each do |feature_name|
        @redis.smembers(feature_history_key(feature_name))
      end
    end

    features.zip(result).each do |feature_name, timestamps|
      timestamps.each do |timestamp|
        history << [timestamp.to_i, feature_name]
      end
    end

    # sort in reverse timestamp order
    history.sort! { |x,y| y.first <=> x.first }
  end

  private
  
  def archived_feature_names_key
    "#{namespace}archived-feature-names"
  end
  
  def feature_names_key
    "#{namespace}feature-names"
  end
  
  def feature_key(feature_name)
    "#{namespace}features/#{feature_name}"
  end
  
  def feature_history_key(feature_name, timestamp = nil)
    key = "#{namespace}feature-history/#{feature_name}"
    key = "#{key}/#{timestamp}" if timestamp
    key
  end

end
