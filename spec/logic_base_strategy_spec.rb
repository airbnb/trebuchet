require 'spec_helper'

describe Trebuchet::Strategy::LogicBase do

  it "should set @feature on sub-strategies" do
    feature = Trebuchet.feature('pokemon')
    feature.aim(
      :logic_and,
      {
        percent: 100,
        users: [30, 35],
      },
    )
    feature.strategy.feature.name.should == 'pokemon'
    feature.strategy.strategies.first.feature.name.should == 'pokemon'
    feature.strategy.strategies.last.feature.name.should == 'pokemon'
  end

  it "should pass user and request to each strategy" do
    args = [:foo, 1]
    user = mock "User"
    request = mock "Request"
    strategy = mock "Strategy"

    Trebuchet::Strategy.should_receive(:find).with(*args).and_return(strategy)
    strategy.should_receive(:launch_at?).with(user, request)
    strategy.should_receive(:needs_user?).and_return(false)

    s = Trebuchet::Strategy::LogicOr.new({foo: 1})
    s.launch_at?(user, request)
  end

end
