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

end
