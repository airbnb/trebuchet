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

end
