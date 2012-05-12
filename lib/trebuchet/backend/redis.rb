require 'redis'
require 'json'

class Trebuchet::Backend::Redis
  
  attr_accessor :namespace
  
  def initialize(*args)
    @namespace = 'trebuchet/'
    begin
      if args.first.is_a?(Hash) && args.first[:client].is_a?(Redis)
        # ignore other args and use provided Redis connection
        @redis = args.first[:client]
      else
        @redis = Redis.new(*args)
      end
      # raise error if not connected
      @redis.exists(feature_names_key) # @redis.info is slow and @redis.client.connected? is NOT reliable
    rescue Exception => e
      raise Trebuchet::BackendInitializationError, e.message
    end
  end

  def get_strategy(feature_name)
    return nil unless h = @redis.hgetall(feature_key(feature_name))
    return nil unless h.is_a?(Hash)
    [].tap do |a|
      h.each do |k, v|
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
    @redis.hset(feature_key(feature_name), strategy, [options].to_json) # have to put options in container for json
    @redis.sadd(feature_names_key, feature_name)
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

end
