require 'spec_helper'

describe Trebuchet::Strategy::Multiple do

  it "should support chaining strategies" do
    Trebuchet.feature('time_machine').aim(:percent, 10).aim(:users, [3, 5])

    yes = [3, 5, 10, 20, 30]
    no  = [1, 2, 4, 6, 7, 8, 9, 11]

    yes.each do |n|
      Trebuchet.new(User.new(n)).launch?('time_machine').should be_true
    end

    no.each do |n|
      Trebuchet.new(User.new(n)).launch?('time_machine').should be_false
    end
  end

end
