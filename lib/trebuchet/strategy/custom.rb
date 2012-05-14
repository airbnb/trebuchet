class Trebuchet::Strategy::Custom < Trebuchet::Strategy::Base

  attr_reader :options, :custom_name

  @@custom_strategies = {}

  def initialize(name, options = nil)
    @custom_name = name
    @options = options
    @block = @@custom_strategies[name]
  end

  def launch_at?(user, request = nil)
    !!(options ? @block.call(user, options) : @block.call(user))
  end

  def self.define(name, block)
    @@custom_strategies[name] = block
  end

  def self.exists?(name)
    @@custom_strategies.has_key?(name)
  end
  
  def needs_user?
    false
  end

end
