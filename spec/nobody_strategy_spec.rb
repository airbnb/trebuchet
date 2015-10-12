require 'spec_helper'

describe Trebuchet::Strategy::Nobody do

  it "should be named nobody" do
    Trebuchet::Strategy::Nobody.strategy_name.should == :nobody
    Trebuchet.feature('time_machine').aim(:nobody)
    Trebuchet.feature('time_machine').strategy.name.should == :nobody
  end

  it "should always return false" do
    Trebuchet.feature('time_machine').aim(:nobody)
    t = Trebuchet.new User.new(1)
    t.launch?('time_machine').should === false
  end

  it "should return false when missing user" do
    Trebuchet.feature('time_machine').aim(:nobody)
    t = Trebuchet.new nil
    t.launch?('time_machine').should === false
  end

end
