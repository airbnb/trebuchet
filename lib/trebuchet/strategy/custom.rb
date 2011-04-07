class Trebuchet::Strategy::Custom

  attr_reader :options

  @@custom_strategies = {}

  def initialize(name, options = nil)
    @name = name
    @options = options
    @block = @@custom_strategies[name]
  end

  def launch_at?(user)
    !!(options ? @block.call(user, options) : @block.call(user))
  end

  def self.define(name, block)
    @@custom_strategies[name] = block
  end

  def self.exists?(name)
    @@custom_strategies.has_key?(name)
  end

end
