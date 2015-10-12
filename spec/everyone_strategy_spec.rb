require 'spec_helper'

describe Trebuchet::Strategy::Everyone do

  it "should be named everyone" do
    Trebuchet::Strategy::Everyone.strategy_name.should == :everyone
    Trebuchet.feature('time_machine').aim(:everyone)
    Trebuchet.feature('time_machine').strategy.name.should == :everyone
  end

  it "should always return true" do
    Trebuchet.feature('time_machine').aim(:everyone)
    t = Trebuchet.new User.new(1)
    t.launch?('time_machine').should === true
  end

  it "should return true when missing user" do
    Trebuchet.feature('time_machine').aim(:everyone)
    t = Trebuchet.new nil
    t.launch?('time_machine').should === true
  end

end
