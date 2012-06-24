require 'spec_helper'

describe Trebuchet::Strategy::Multiple do

  it "should support chaining strategies" do
    Trebuchet.feature('time_machine').aim(:percent, 10).aim(:users, [10, 11])
    offset = 72 # for "time_machine"
    should_launch('time_machine', [0-offset, 9-offset, 10, 11])
    should_not_launch('time_machine', [23, 42])
  end
  
  it "should always return booleans" do
    Trebuchet.feature('time_machine').aim(:percent, 0).aim(:users, [5])
    t = Trebuchet.new User.new(5)
    t.launch?('time_machine').should === true
    t = Trebuchet.new User.new(117)
    t.launch?('time_machine').should === false
  end
  
  it "should set @feature on sub-strategies" do
    feature = Trebuchet.feature('time_machine')
    feature.aim(:percent, 10).aim(:users, [5])
    feature.strategy.feature.name == feature.name
    feature.strategy.strategies.first.feature.name.should == feature.name
    feature.strategy.strategies.last.feature.name.should == feature.name
  end

  it "should pass user and request to each strategy" do
    args = [:foo, 1]
    user = mock "User"
    request = mock "Request"
    strategy = mock "Strategy"

    Trebuchet::Strategy.should_receive(:find).with(*args).and_return(strategy)
    strategy.should_receive(:launch_at?).with(user, request)

    multi = Trebuchet::Strategy::Multiple.new(args)
    multi.launch_at?(user, request)
  end
  
  it "should always return false for needs_user?" do
    s = Trebuchet::Strategy::Multiple.new [:default, nil, :invalid, nil]
    s.needs_user?.should be_false
    s = Trebuchet::Strategy::Multiple.new [:default, nil, :percent, 5]
    s.needs_user?.should be_false
  end

  it "should skip needs_user? sub-strategies if user not present" do
    s = Trebuchet::Strategy::Multiple.new [:hostname, 'abc', :users, [1,2,3]]
    s.strategies.first.should_receive(:launch_at?)
    s.strategies.last.should_not_receive(:launch_at?)
    s.launch_at?(nil)
  end

end
