require 'spec_helper'

describe Trebuchet::Strategy::LogicOr do

  it "passes the check as long as one of the children strategies passes" do
    Trebuchet.feature('pokemon').aim(
      :logic_or,
      {
        users: [30, 35],
        everyone: nil,
        nobody: nil,
        percent: 30,
      },
    )

    [1, 9, 91, 92, 2016].each do |uid|
      t = Trebuchet.new(User.new(uid))
      t.launch?('pokemon').should === true
    end
  end

  it "is not launching if no children strategy works" do
    Trebuchet.feature('pokemon').aim(
      :logic_or,
      {
        percent: 0,
        users: [30, 35],
      },
    )

    t = Trebuchet.new(User.new(30))
    t.launch?('pokemon').should === true
    t = Trebuchet.new(User.new(111))
    t.launch?('pokemon').should === false
  end

  it "nests well" do
    Trebuchet.feature('pokemon').aim(
      :logic_or,
      {
        users: [100],
        logic_and: {
          users: [90, 91, 92],
          logic_not: {
            users: [90],
          },
        },
      },
    )

    [91, 92, 100].each do |uid|
      t = Trebuchet.new(User.new(uid))
      t.launch?('pokemon').should === true
    end
    [1, 3, 5, 7, 90].each do |uid|
      t = Trebuchet.new(User.new(uid))
      t.launch?('pokemon').should === false
    end
  end

end
