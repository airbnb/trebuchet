require 'spec_helper'

describe Trebuchet::Strategy::VisitorExperiment do
  
  before do
    @feature_name = "Infrared Vision"
    @feature_name2 = "Alligator Tail"
    @experiment_name = "Superhumanity"
    @user = User.new(0)
    @mock_request = mock_request('abcdef')
    @trebuchet = Trebuchet.new(@user, @mock_request)
  end

  it "should match a user in a bucket" do
    Trebuchet.aim(@feature_name, :visitor_experiment, :name => @experiment_name, :bucket => 1)
    should_not_launch(@feature_name, (1..50).to_a) # should never launch without a request
    # these values just happen to hash for the algorithm and experiment name
    positive = [5, 14, 15, 198, 200, 549]
    negative = [1, 2, 25, 550]
    positive.each do |i|
      Trebuchet.visitor_id = i
      Trebuchet.feature(@feature_name).launch_at?(@user, @mock_request).should be_true
    end
    negative.each do |i|
      Trebuchet.visitor_id = i
      Trebuchet.feature(@feature_name).launch_at?(@user, @mock_request).should be_false
    end
  end
  
  it "should launch nil request to no bucket" do
    Trebuchet.aim(@feature_name, :visitor_experiment, :name => @experiment_name, :total_buckets => 2, :bucket => 1)
    Trebuchet.aim(@feature_name2, :visitor_experiment, :name => @experiment_name, :total_buckets => 2, :bucket => 2)
    Trebuchet.visitor_id = nil
    @trebuchet.launch?(@feature_name).should be_false
    @trebuchet.launch?(@feature_name2).should be_false
  end
  

end
