require 'spec_helper'
require 'mock_redis'
require 'trebuchet/backend/redis_hammerspaced'


describe Trebuchet::Backend::RedisHammerspaced do

  before(:all) do
    @backend = Trebuchet.backend
  end

  before(:each) do
    Trebuchet.set_backend :disabled
  end

  it "should properly get empty feature names and strategies" do
    r = Redis.new
    Redis.stub!(:new).and_return(nil)
    Trebuchet.backend.should be_a(Trebuchet::Backend::Disabled)
    Trebuchet.backend.instance_variable_get(:@redis).should be_nil
    Trebuchet.set_backend :redis_hammerspaced,
                          :client => r,
                          :hammerspace => {},
                          :skip_check => true
    Trebuchet.backend.get_feature_names.should eq []
    Trebuchet.backend.get_strategy("adfd").should be_nil
  end

  it "should properly get feature name list and non-empty strategies" do
    r = Redis.new
    Redis.stub!(:new).and_return(nil)
    Trebuchet.backend.should be_a(Trebuchet::Backend::Disabled)
    Trebuchet.backend.instance_variable_get(:@redis).should be_nil
    Trebuchet.set_backend :redis_hammerspaced,
                          :client => r,
                          :hammerspace => {
                            "trebuchet/feature-names" => ["foo", "bar"].to_s, # stringified array
                            "trebuchet/features/foo" => {
                              "everyone" => nil,
                              "users" => [1, 2, 3],
                            }.to_json, # stringified json
                          },
                          :skip_check => true
    Trebuchet.backend.get_feature_names.should eq ["foo", "bar"]
    Trebuchet.backend.get_strategy("foo").should eq [:everyone, nil, :users, [1, 2, 3]]
  end

  after(:all) do
    # cleanup
    Trebuchet.backend = @backend
  end

end