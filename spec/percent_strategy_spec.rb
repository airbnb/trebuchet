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
  
  
  def offset_ids(ids, offset)
    ids.to_a.map {|id| id + offset % 100} 
  end
  
  
  it "should launch to the right users with percentage" do
    Trebuchet.feature('freedom').aim(:percent, :percentage => 50)
    offset = Trebuchet.feature('freedom').strategy.offset
    should_launch 'freedom', offset_ids(0..49, offset)
    should_not_launch 'freedom',  offset_ids(50..99, offset)
    should_launch 'freedom',  offset_ids(100..149, offset)
    should_not_launch 'freedom',  offset_ids(150..199, offset)
    should_launch'freedom',  offset_ids([200, 201], offset)
    should_not_launch 'freedom',  offset_ids([250, 251], offset)
  end
  
  it "should launch to the right users with wrap" do
    Trebuchet.feature('freedom').aim(:percent, :from => 99, :to => 1)
    should_launch 'freedom', [0, 1, 99, 100, 101, 199, 200, 201, 299]
    should_not_launch 'freedom', [97, 98, 102, 103, 198, 202, 298, 302]
  end
  
  it "should launch to 1%" do
    Trebuchet.feature('freedom').aim(:percent, :percentage => 1)
    offset = Trebuchet.feature('freedom').strategy.offset
    should_launch 'freedom', offset_ids([100, 200, 300, 0], offset)
    should_not_launch 'freedom', offset_ids([1, 99, 101, 198, 202, 350], offset)
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
  
  it "works with from/to > 100" do
    # just documenting this side-effect
    Trebuchet.feature('freedom').aim(:percent, :from => 105, :to => 210)
    should_launch 'freedom', [5, 106, 207, 308, 409, 1210]
    should_not_launch 'freedom', [4, 99, 111, 150, 215]
  end

end