require 'spec_helper'

describe Trebuchet::Strategy::Default do

  it "should not launch if no strategy was defined" do
    Trebuchet.new(User.new(rand(2 << 32))).launch?('default').should be_false
  end

end
