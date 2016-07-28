require 'spec_helper'

describe Trebuchet::Strategy::LogicAnd do

  it "passes the check only when all conditions are met - case 1" do
    Trebuchet.feature('pokemon').aim(
      :logic_and,
      {
        percent: 0,
        users: [30, 35],
      },
    )

    t = Trebuchet.new(User.new(30))
    t.launch?('pokemon').should === false
    t = Trebuchet.new(User.new(111))
    t.launch?('pokemon').should === false
  end

  it "passes the check only when all conditions are met - case 2" do
    Trebuchet.feature('pokemon').aim(
      :logic_and,
      {
        percent: 100,
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
      :logic_and,
      {
        "percent" => 100,
        "logic_and" => {
          "users" => [90, 91, 92],
          "logic_not" => {
            "users" => [90],
          },
        },
      },
    )

    [91, 92].each do |uid|
      t = Trebuchet.new(User.new(uid))
      t.launch?('pokemon').should === true
    end
    [1, 3, 5, 7, 90].each do |uid|
      t = Trebuchet.new(User.new(uid))
      t.launch?('pokemon').should === false
    end
  end

end
