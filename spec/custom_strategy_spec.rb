require 'spec_helper'

describe Trebuchet::Strategy::Custom do

  it "should launch according to the custom strategy" do
    Trebuchet.define_strategy(:admins) do |current_user|
      current_user.has_role?(:admin)
    end

    Trebuchet.aim('admin_feature', :admins)

    Trebuchet.new(User.new(1, :admin)).launch?('admin_feature').should be_true
    Trebuchet.new(User.new(1, :user)).launch?('admin_feature').should be_false
  end

  it "should pass arguments to the custom strategy" do
    Trebuchet.define_strategy(:role) do |current_user, role|
      current_user.has_role?(role.to_sym)
    end

    Trebuchet.aim('power_feature', :role, :power_user)

    Trebuchet.new(User.new(1, :power_user)).launch?('power_feature').should be_true
    Trebuchet.new(User.new(1, :user)).launch?('power_feature').should be_false
  end
  
  it "should allow an always-on strategy" do
    Trebuchet.define_strategy(:yes) { |user| true }
    Trebuchet.aim("perma-feature", :yes)
    Trebuchet.new(User.new 999).launch?("perma-feature").should be_true
    Trebuchet.new(User.new nil).launch?("perma-feature").should be_true
  end
  
  it "should needs_user? based on block arity" do
    # still a good idea to nilcheck within block however
    Trebuchet.define_strategy(:yes) { |user| true }
    Trebuchet.define_strategy(:heck_yeah) { |user, request| true }
    Trebuchet.define_strategy(:never) { false }
    Trebuchet.define_strategy(:always) { true }
    Trebuchet::Strategy::Custom.new(:yes).needs_user?.should be_true
    Trebuchet::Strategy::Custom.new(:heck_yeah).needs_user?.should be_true
    Trebuchet::Strategy::Custom.new(:never).needs_user?.should be_false
    Trebuchet::Strategy::Custom.new(:always).needs_user?.should be_false
  end

end
