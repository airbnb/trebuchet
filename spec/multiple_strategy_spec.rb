require 'spec_helper'

describe Trebuchet::Strategy::Multiple do

  it "should support chaining strategies" do
    Trebuchet.feature('time_machine').aim(:percent, 10).aim(:users, [10, 11])

    should_launch('time_machine', [0, 9, 10, 11])
    should_not_launch('time_machine', [23, 42])
  end

end
