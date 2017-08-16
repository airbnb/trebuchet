class Trebuchet::Strategy::CustomRequestAware < Trebuchet::Strategy::Custom
  @@custom_request_aware_strategies = {}

  def initialize(name, options = nil)
    @custom_name = name
    @options = options
    @block = @@custom_request_aware_strategies[name]
  end

  def self.define(name, block)
    @@custom_request_aware_strategies[name] = block
  end

  def self.exists?(name)
    @@custom_request_aware_strategies.has_key?(name)
  end

  def launch_at?(user, request = nil)
    request ||= {}
    !!(options ? @block.call(user, request, options) : @block.call(user, request))
  end

  def to_s
    "#{custom_name} (custom_request_aware) #{options.inspect if options}"
  end
end
