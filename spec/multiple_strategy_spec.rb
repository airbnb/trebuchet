require 'spec_helper'

describe Trebuchet::Strategy::Multiple do

  it "should support chaining strategies" do
    Trebuchet.feature('time_machine').aim(:percent, 10).aim(:users, [10, 11])

    should_launch('time_machine', [0, 9, 10, 11])
    should_not_launch('time_machine', [23, 42])
  end
  
  it "should always return booleans" do
    Trebuchet.feature('time_machine').aim(:percent, 0).aim(:users, [5])
    t = Trebuchet.new User.new(5)
    t.launch?('time_machine').should === true
    t = Trebuchet.new User.new(117)
    t.launch?('time_machine').should === false
  end

end
