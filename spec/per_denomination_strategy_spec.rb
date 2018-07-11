require 'spec_helper'

describe Trebuchet::Strategy::PerDenomination do
  describe 'launch' do
    before(:each) do
      Trebuchet.aim('strategy', :per_denomination, { numerator: 50, denominator: 1000 })
    end

    it "should not launch to unsaved users" do
      Trebuchet.new(nil).launch?('strategy').should be_false
    end

    it "should not launch to users with no IDs" do
      Trebuchet.new(User.new(nil)).launch?('strategy').should be_false
    end

    it "should launch to the correct per_denomination of users" do
      launched_users =
        (1..10_000).select { |i| Trebuchet.new(User.new(i)).launch?('strategy') }.size

      unlaunched_users =
        (1..10_000).reject { |i| Trebuchet.new(User.new(i)).launch?('strategy') }.size

      # If you run this to larger N it approaches .95 and 0.05. This is
      # hash function dependent but it's a nice santity check.
      launched_users.should be_within(200).of(500)
      unlaunched_users.should be_within(200).of(9500)
    end
  end

  it "should not yank the feature from users when per_denomination is increased" do
    Trebuchet.aim('strategy', :per_denomination, { numerator: 10, denominator: 1000 })

    first_launched_users =
      (1..10_000).select { |i| Trebuchet.new(User.new(i)).launch?('strategy') }

    Trebuchet.aim('strategy', :per_denomination, { numerator: 50, denominator: 1000 })

    second_launched_users =
      (1..10_000).select { |i| Trebuchet.new(User.new(i)).launch?('strategy') }

    (second_launched_users & first_launched_users).should eq first_launched_users
  end

  it "should distribute launches based on the feature name" do
    Trebuchet.aim('strategy1', :per_denomination, { numerator: 50, denominator: 1000 })
    Trebuchet.aim('strategy2', :per_denomination, { numerator: 50, denominator: 1000 })

    per_denomination1_launched_users =
      (1..10_000).select { |i| Trebuchet.new(User.new(i)).launch?('strategy1') }
    per_denomination2_launched_users =
      (1..10_000).select { |i| Trebuchet.new(User.new(i)).launch?('strategy2') }

    per_denomination1_launched_users.should_not eq per_denomination2_launched_users
  end

  it "should always return booleans" do
    Trebuchet.aim('strategy', :per_denomination, { numerator: 50, denominator: 1000 })
    (1..10_000).each do |i|
      [true, false].should include(Trebuchet.new(User.new(i)).launch?('strategy'))
    end
  end

  it "should handle 0 numerator" do
    Trebuchet.aim('strategy', :per_denomination, { numerator: 0, denominator: 1000 })
    should_not_launch 'strategy', (1..10_000).to_a
  end

  it "should fail on 0 denominator" do
    Trebuchet.aim('strategy', :per_denomination, { numerator: 1000, denominator: 0 })
    should_not_launch 'strategy', (1..10_000).to_a # trebuchet silently fails all invalid strategies
  end

  it "should handle numerator == denominator" do
    Trebuchet.aim('strategy', :per_denomination, { numerator: 1000, denominator: 1000 })
    should_launch 'strategy', (1..10_000).to_a
  end

  it "should fail when numerator > denominator" do
    Trebuchet.aim('strategy', :per_denomination, { numerator: 1001, denominator: 1000 })
    should_not_launch 'strategy', (1..10_000).to_a # trebuchet silently fails all invalid strategies
  end

  it "should handle garbage arguments" do
    ids = (1..20_000).to_a
    Trebuchet.feature('strategy').aim(:per_denomination, -1)
    should_not_launch 'strategy', ids
    Trebuchet.feature('strategy').aim(:per_denomination, -150)
    should_not_launch 'strategy', ids
    Trebuchet.feature('strategy').aim(:per_denomination, 'h')
    should_not_launch 'strategy', ids
    Trebuchet.feature('strategy').aim(:per_denomination, 'h')
    should_not_launch 'strategy', ids
    Trebuchet.feature('strategy').aim(:per_denomination, [5, 10])
    should_not_launch 'strategy', ids
    Trebuchet.feature('strategy').aim(:per_denomination, 20..50)
    should_not_launch 'strategy', ids
    Trebuchet.feature('strategy').aim(:per_denomination, nil)
    should_not_launch 'strategy', ids
    Trebuchet.feature('strategy').aim(:per_denomination, :from => 7)
    should_not_launch 'strategy', ids
    Trebuchet.feature('strategy').aim(:per_denomination, :to => 1)
    should_not_launch 'strategy', ids
  end
end

