require 'spec_helper'

describe Trebuchet::Strategy::UserId do

  it "should only launch to designated users" do
    Trebuchet.aim('highly_experimental', :users, [1, 2])
    yes = [1, 2]
    no  = [3, 4]

    yes.each do |n|
      Trebuchet.new(User.new(n)).launch?('highly_experimental').should be_true
    end

    no.each do |n|
      Trebuchet.new(User.new(n)).launch?('highly_experimental').should be_false
    end
  end
  
  it "should always return booleans" do
    Trebuchet.feature('time_machine').aim(:users, [1])
    t = Trebuchet.new User.new(1)
    t.launch?('time_machine').should === true
    t = Trebuchet.new User.new(117)
    t.launch?('time_machine').should === false
  end

  # this behavior should be deprecated -- causes problems with augment
  it "should not break if one id is passed instead of an array" do
    Trebuchet.feature('time_machine').aim(:users, 1)
    t = Trebuchet.new User.new(1)
    t.launch?('time_machine').should === true
  end
  
  it "should not break on missing user" do
    Trebuchet.feature("the chosen ones").aim(:users, [1,2,3])
    t = Trebuchet.new User.new(nil)
    t.launch?("the chosen ones").should be_false
    t = Trebuchet.new nil
    t.launch?("the chosen ones").should be_false
  end

end
