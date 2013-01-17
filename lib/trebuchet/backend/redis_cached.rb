require 'trebuchet/backend/redis'

class Trebuchet::Backend::RedisCached < Trebuchet::Backend::Redis

  # cache strategies in memory until clear_cached_strategies is called

  def get_strategy(feature_name)
    if cached_strategies.has_key?(feature_name)
      # use cached if available (even if value is nil)
      cached_strategies[feature_name]
    else
      # or call Trebuchet::Backend::Redis#get_strategy
      # which will fetch from Redis and unpack json
      # and then cache it for next time
      cache_strategy feature_name, super(feature_name)
    end
  end

  def append_strategy(feature_name, strategy, options = nil)
    # though we can't clear the strategy for all active instances
    # this will clear the cache in the console environment to show current settings
    self.clear_cached_strategies
    super(feature_name, strategy, options)
  end

  def cache_strategy(feature_name, strategy)
    cached_strategies[feature_name] = strategy
    return strategy
  end

  def cached_strategies
    @cached_strategies ||= Hash.new
  end

  def cache_cleared_at
    @cache_cleared_at ||= Time.now
  end

  def clear_cached_strategies
    @cache_cleared_at = Time.now
    @cached_strategies = nil
  end

end
