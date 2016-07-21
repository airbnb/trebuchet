require 'spec_helper'

describe Trebuchet::Strategy::LogicNot do

  it "works expectedly as a not operator" do
    Trebuchet.feature('pokemon').aim(
      :logic_not,
      {
        users: [30, 35],
      },
    )

    t = Trebuchet.new(User.new(30))
    t.launch?('pokemon').should === false
    t = Trebuchet.new(User.new(111))
    t.launch?('pokemon').should === true
  end

end
