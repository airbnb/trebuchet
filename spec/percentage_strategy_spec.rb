require 'spec_helper'

describe Trebuchet::Strategy::Percentage do

  it "should only launch to a percentage of users" do
    Trebuchet.aim('percentage', :percent, 10)
    yes = [10, 20, 30]
    no  = [1, 2, 3, 4, 5, 6, 7, 8, 9, 11]

    yes.each do |n|
      Trebuchet.new(User.new(n)).launch?('percentage').should be_true
    end

    no.each do |n|
      Trebuchet.new(User.new(n)).launch?('percentage').should be_false
    end
  end

end
