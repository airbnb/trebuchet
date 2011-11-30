require 'spec_helper'

describe Trebuchet::Strategy::Default do

  it "should not launch if no strategy was defined" do
    Trebuchet.new(User.new(rand(2 << 32))).launch?('default').should be_false
  end
  
  it "should be named default" do
    Trebuchet::Strategy::Default.strategy_name.should == :default
    Trebuchet.feature('whatever').strategy.name.should == :default
  end

end
