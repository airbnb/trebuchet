require 'spec_helper'

describe Trebuchet::Strategy::Percentage do

  it "should only launch to a percentage of users" do
    Trebuchet.aim('percentage', :percent, 5)
    should_launch('percentage', [0, 1, 2, 3, 4, 100, 101, 102, 103, 104])
    should_not_launch('percentage', [5, 6, 105, 106])
  end

  it "should not yank the feature from users when percentage is increased" do
    Trebuchet.aim('percentage', :percent, 2)
    should_launch('percentage', [0, 1])
    should_not_launch('percentage', [2, 3])

    Trebuchet.aim('percentage', :percent, 4)
    should_launch('percentage', [0, 1, 2, 3])
  end

end
