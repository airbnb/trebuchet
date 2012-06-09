class Trebuchet::Strategy::Multiple < Trebuchet::Strategy::Base

  attr_reader :strategies

  def initialize(args)
    @strategies = []
    args.each_slice(2) do |pair|
      @strategies << Trebuchet::Strategy.find(*pair)
    end
  end
  
  # override setter so that @feature gets set on @strategies as well
  def feature=(f)
    @feature = f
    @strategies.each {|s| s.feature = f}
  end

  def launch_at?(user, request = nil)
    !!(strategies.find { |s| s.launch_at?(user, request) })
  end
  
  def as_json(options = {})
    @strategies
  end
  
  def needs_user?
    false # assume some of the strategies may not need user
    # could change this so it calls only the strategies that don't need a user when none is present
    # strategies.any? { |s| s.needs_user? }
  end

end
