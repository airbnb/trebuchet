require 'spec_helper'

describe Trebuchet::Strategy::Percentage do
  
  def offset
    99 # only works if feature name is 'percentage'
  end

  it "should not launch to unsaved users, users with no IDs" do
    Trebuchet.aim('percentage', :percent, 5)
    Trebuchet.new(nil).launch?('percentage').should be_false
    Trebuchet.new(User.new(nil)).launch?('percentage').should be_false
  end

  it "should only launch to a percentage of users" do
    Trebuchet.aim('percentage', :percent, 5)
    should_launch('percentage', [0, 1, 2, 3, 4, 100, 101, 102, 103, 104].map{|i| i - offset})
    should_not_launch('percentage', [5, 6, 105, 106].map{|i| i - offset})
  end

  it "should not yank the feature from users when percentage is increased" do
    Trebuchet.aim('percentage', :percent, 2)
    should_launch('percentage', [0, 1].map{|i| i - offset})
    should_not_launch('percentage', [2, 3].map{|i| i - offset})

    Trebuchet.aim('percentage', :percent, 4)
    should_launch('percentage', [0, 1, 2, 3].map{|i| i - offset})
  end
  
  it "should create an offset based on the feature name" do
    Trebuchet.aim('percentage', :percent, 1)
    should_launch('percentage', [0 - offset])
    should_not_launch('percentage', [0 - (offset - 1)])
    should_not_launch('percentage', [0 - (offset + 1)])
  end
  
  it "should always return booleans" do
    Trebuchet.feature('percentage').aim(:percent, 1)
    t = Trebuchet.new User.new(0 - offset)
    t.launch?('percentage').should === true
    t = Trebuchet.new User.new(0 - (offset - 1))
    t.launch?('percentage').should === false
  end

end