require 'memcache'

class Trebuchet::Backend::Memcached

  attr_accessor :namespace

  def initialize(*args)
    @memcache = MemCache.new(*args)
    @namespace = 'trebuchet/'
  end

  def get_strategy(feature_name)
    @memcache.get(key(feature_name))
  end

  def set_strategy(feature, strategy, options = nil)
    @memcache.set(key(feature), [strategy, options])
  end

  def append_strategy(feature, strategy, options = nil)
    @memcache.set(key(feature), get_strategy(feature) + [strategy, options])
  end

  private

  def key(feature_name)
    "#{namespace}#{feature_name}"
  end

end
