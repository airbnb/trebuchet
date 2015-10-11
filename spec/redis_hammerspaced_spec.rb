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
                              "everyone" => [nil],
                              "users" => [[1, 2, 3]],
                            }.to_json, # stringified json
                          },
                          :skip_check => true
    Trebuchet.backend.get_feature_names.should eq ["foo", "bar"]
    Trebuchet.backend.get_strategy("foo").should eq [:everyone, nil, :users, [1, 2, 3]]
  end

  it "should properly invalidate local cache" do
    r = Redis.new
    Redis.stub!(:new).and_return(nil)
    hammerspace = {
      "trebuchet/feature-names" => ["foo", "bar"].to_s,
      "trebuchet/features/foo" => {
        "everyone" => [nil],
        "users" => [[1, 2, 3]],
      }.to_json
    }
    def hammerspace.uid
      @uid ||= Time.now().to_i
      @uid = @uid + 1
    end
    def hammerspace.close
    end
    Trebuchet.set_backend :redis_hammerspaced,
                          :client => r,
                          :hammerspace => hammerspace,
                          :skip_check => true
    # Force to load strategy to local cache
    Trebuchet.backend.get_strategy("foo")
    hammerspace["trebuchet/features/foo"] = {
      "everyone" => [nil],
      "users" => [[1, 2]],
    }.to_json
    Trebuchet.backend.get_strategy("foo").should eq [:everyone, nil, :users, [1, 2, 3]]
    # after refresh we should have the up-to-date strategy
    Trebuchet.backend.refresh
    Trebuchet.backend.get_strategy("foo").should eq [:everyone, nil, :users, [1, 2]]
  end

  it "should properly generate hammerspace hash" do
    r = Redis.new
    Redis.stub!(:new).and_return(nil)
    Trebuchet.set_backend :redis_hammerspaced,
                          :client => r,
                          :hammerspace => {},
                          :skip_check => true
    feature_names = ["foo", "bar"]
    features = [
      ["everyone", "[null]", "user", "[[1,2,3]]"], # foo
      ["visitor_experiment", "[{\"name\":\"rate\",\"total_buckets\":5,\"bucket\":1}]"] # bar
    ]
    foo_string = {
      "everyone" => [nil],
      "user" => [[1,2,3]],
    }.to_json
    bar_string = {
      "visitor_experiment" => [
        {
          "name" => "rate",
          "total_buckets" => 5,
          "bucket" => 1,
        }
      ],
    }.to_json
    last_updated = Time.now.to_i
    expected_hash = {
      "trebuchet/feature-names" => feature_names.to_json,
      "trebuchet/features/foo" => foo_string,
      "trebuchet/features/bar" => bar_string,
      "trebuchet/last_updated" => last_updated.to_s,
    }
    Trebuchet.backend.generate_hammerspace_hash(
      feature_names,
      features,
      last_updated
    ).should eq expected_hash
  end

  after(:all) do
    # cleanup
    Trebuchet.backend = @backend
  end

end
