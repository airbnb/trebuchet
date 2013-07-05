require 'spec_helper'

describe Trebuchet::Strategy::Percent do

  it "should not launch to unsaved users, users with no IDs" do
    Trebuchet.aim('percentage', :percent, 5)
    Trebuchet.new(nil).launch?('percentage').should be_false
    Trebuchet.new(User.new(nil)).launch?('percentage').should be_false
  end

  it "should only launch to a percentage of users" do
    Trebuchet.aim('percentage', :percent, 5)
    should_launch 'percentage', [7, 24, 74, 75]
    should_not_launch('percentage', [47, 48, 49, 76, 78])
  end

  it "should launch to the correct percentage of users" do
    Trebuchet.aim('percentage', :percent, 5)
    map = Hash.new {|a,k| a[k] = 0 }
    n = 20000
    n.times do |i|
      map[Trebuchet.new(User.new(i)).launch?('percentage')] +=  1
    end
    map.each {|k, v|
      map[k] = v / n.to_f
    }
    # If you run this to larger N it approaches .95 and 0.05. This is
    # hash function dependent but it's a nice santity check.
    map[false].should be_close(0.95, 0.02)
    map[true].should be_close(0.05, 0.02)
  end

  it "should not yank the feature from users when percentage is increased" do
    Trebuchet.aim('percentage', :percent, 2)

    should_launch 'percentage', [7, 74]
    should_not_launch 'percentage', [24, 147]

    Trebuchet.aim('percentage', :percent, 4)
    should_launch 'percentage', [7, 74, 24, 147]
  end

  it "should distribute launches based on the feature name" do
    Trebuchet.aim('percentage1', :percent, 1)
    Trebuchet.aim('percentage2', :percent, 1)
    should_launch 'percentage1', [9, 145, 186]
    should_not_launch 'percentage2', [9, 145, 186]
    should_launch 'percentage2', [21, 47]
    should_not_launch 'percentage1', [21, 47]
  end

  it "should always return booleans" do
    Trebuchet.aim('percentage1', :percent, 1)
    t = Trebuchet.new(User.new(9))
    t.launch?('percentage1').should === true
    t = Trebuchet.new(User.new(21))
    t.launch?('percentage1').should === false
  end

  it "should handle 0%" do
    Trebuchet.feature('freedom').aim(:percent, 0)
    should_not_launch 'freedom', (1..200).to_a
  end

  it "should handle garbage arguments" do
    ids = (1..200).to_a
    Trebuchet.feature('freedom').aim(:percent, -1)
    should_not_launch 'freedom', ids
    Trebuchet.feature('freedom').aim(:percent, -150)
    should_not_launch 'freedom', ids
    Trebuchet.feature('freedom').aim(:percent, 'h')
    should_not_launch 'freedom', ids
    Trebuchet.feature('freedom').aim(:percent, 'h')
    should_not_launch 'freedom', ids
    Trebuchet.feature('freedom').aim(:percent, [5, 10])
    should_not_launch 'freedom', ids
    Trebuchet.feature('freedom').aim(:percent, 20..50)
    should_not_launch 'freedom', ids
    Trebuchet.feature('freedom').aim(:percent, nil)
    should_not_launch 'freedom', ids
    Trebuchet.feature('freedom').aim(:percent, :from => 7)
    should_not_launch 'freedom', ids
    Trebuchet.feature('freedom').aim(:percent, :to => 1)
    should_not_launch 'freedom', ids
  end

end

