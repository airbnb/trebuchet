class Trebuchet::Strategy::LogicBase < Trebuchet::Strategy::Base

  attr_reader :strategies
  attr_reader :options

  def initialize(options = {})
    @options = options
    @strategies = []
    options.each do |strategy_name, strategy_options|
      @strategies << Trebuchet::Strategy.find(strategy_name.to_sym, strategy_options)
    end
  end

  # Override feature setter so that @feature gets set on @strategies as well
  def feature=(f)
    @feature = f
    @strategies.each { |s| s.feature = f }
  end

  def launch_at?(user, request = nil)
    false # To be overriden in implementation classes.
  end

  def needs_user?
    false
  end

end