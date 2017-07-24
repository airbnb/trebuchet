require 'spec_helper'

describe Trebuchet::Strategy::CustomRequestAware do
  it "should launch according to the custom strategy with options" do
    Trebuchet.define_request_aware_strategy(:ip_address_strategy) do |current_user, request, ip_address|
      request[:ip_address] == ip_address
    end

    Trebuchet.aim('ip_limited_feature', :ip_address_strategy, '1.1.1.1')

    Trebuchet.new(User.new, { :ip_address => '1.1.1.1' }).launch?('ip_limited_feature')
      .should be_true
    Trebuchet.new(User.new, { :ip_address => '2.2.2.2' }).launch?('ip_limited_feature')
      .should be_false
  end

  it "should launch according to the custom strategy without options" do
    Trebuchet.define_request_aware_strategy(:ip_address_strategy) do |current_user, request|
      request[:ip_address] == '1.1.1.1'
    end

    Trebuchet.aim('ip_limited_feature', :ip_address_strategy)

    Trebuchet.new(User.new, { :ip_address => '1.1.1.1' }).launch?('ip_limited_feature')
      .should be_true
    Trebuchet.new(User.new, { :ip_address => '2.2.2.2' }).launch?('ip_limited_feature')
      .should be_false
  end

  it "should not explode when request is nil" do
    Trebuchet.define_request_aware_strategy(:ip_address_strategy) do |current_user, request|
      request[:ip_address] == '1.1.1.1'
    end

    Trebuchet.aim('ip_limited_feature', :ip_address_strategy)

    Trebuchet.new(User.new).launch?('ip_limited_feature').should be_false
  end
end
