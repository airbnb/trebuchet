require 'spec_helper'
require 'mock_redis'
require 'trebuchet/backend/redis'


describe Trebuchet::Backend::Redis do

  before(:all) do
    @backend = Trebuchet.backend
  end

  before(:each) do
    Trebuchet.set_backend :disabled
  end

  it "should set backend to redis with defaults" do
    Trebuchet.backend = :redis
    Trebuchet.backend.should be_a(Trebuchet::Backend::Redis)
    Trebuchet.set_backend :redis
    Trebuchet.backend.should be_a(Trebuchet::Backend::Redis)
  end
  
  it "should set redis client if passed in" do
    r = Redis.new
    Redis.stub!(:new).and_return(nil)
    lambda {Trebuchet.set_backend :redis}.should raise_error Trebuchet::BackendInitializationError
    Trebuchet.backend.should be_a(Trebuchet::Backend::Disabled)
    Trebuchet.backend.instance_variable_get(:@redis).should be_nil
    Trebuchet.set_backend :redis, :client => r
    Trebuchet.backend.instance_variable_get(:@redis).should eql r
  end
  
  it "should pass arguments to Redis.new" do
    r = Redis.new
    Redis.should_receive(:new).with(:this => 'that', :other => true).and_return(r)
    Trebuchet.set_backend :redis, :this => 'that', :other => true
    args = [:seven, {8 => 'nine'}]
    Redis.should_receive(:new).with(*args).and_return(r)
    Trebuchet.set_backend :redis, *args
  end
  
  after(:all) do
    # cleanup
    Trebuchet.backend = @backend
  end
 

end
