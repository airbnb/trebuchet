require 'spec_helper'

describe Trebuchet::Strategy::VisitorPercentDeprecated do

  it "should be deprecated" do
    Trebuchet::Feature.with_deprecated_strategies_enabled(false) do
      expect {
        Trebuchet.aim('some_feature', :visitor_percent_deprecated, 5)
      }.to raise_error(/deprecated/)
    end
  end

  it "should not break if no visitor id is set" do
    Trebuchet.aim('some_feature', :visitor_percent_deprecated, 100)
    t = Trebuchet.new(User.new(0))
    t.launch?('some_feature').should == false
  end

  it "should require a request" do
    Trebuchet.visitor_id = 1
    Trebuchet.aim('some_feature', :visitor_percent_deprecated, 100)
    t = Trebuchet.new(User.new(1), nil)
    t.launch?('some_feature').should == false
  end

  it "should not require a user" do
    Trebuchet.visitor_id = 1
    Trebuchet.aim('some_feature', :visitor_percent_deprecated, 100)
    t = Trebuchet.new(nil, mock_request('12345'))
    t.launch?('some_feature').should == true
  end

  describe 'visitor id integer' do
    before do
      Trebuchet.visitor_id = 123
    end

    def should_launch_test(feature_name)
      # offset of some_feature is 33
      Trebuchet.aim('some_feature', feature_name, 100)
      offset = Trebuchet.feature('some_feature').strategy.offset
      user = User.new(0)
      request = mock_request('12345')
      Trebuchet.feature('some_feature').launch_at?(user, request).should == true
      visitor_id = Trebuchet.visitor_id.call

      Trebuchet.aim('some_feature', feature_name, 91) # 33 + 91 includes 123 % 100
      Trebuchet.feature('some_feature').launch_at?(user, request).should == true

      Trebuchet.aim('some_feature', feature_name, 90)
      Trebuchet.feature('some_feature').launch_at?(user, request).should == false
    end

    it 'should launch' do
      should_launch_test(:visitor_percent_deprecated)
    end
  end

  describe 'visitor id proc' do
    before do
      Trebuchet.visitor_id = proc { |request| request && request.cookies[:visitor] && request.cookies[:visitor].hash }
    end

    it 'should not launch if no request is present' do
      Trebuchet.aim('some_feature', :visitor_percent_deprecated, 100)
      should_not_launch('some_feature', [1000])
    end

    it 'should launch to a valid session' do
      Trebuchet.aim('some_feature', :visitor_percent_deprecated, 100)
      t = Trebuchet.new(User.new(0), mock_request('abcdef'))
      t.launch?('some_feature').should == true
    end

    it 'should not launch to a nil session ID' do
      Trebuchet.aim('some_feature', :visitor_percent_deprecated, 100)
      t = Trebuchet.new(User.new(0), mock_request(nil))
      t.launch?('some_feature').should == false
    end
  end

  describe 'visitor id invalid' do
    it "should handle nil" do
      Trebuchet.visitor_id = nil
      Trebuchet.aim('some_feature', :visitor_percent_deprecated, 100)
      t = Trebuchet.new(User.new(0), mock_request('abcdef'))
      t.launch?('some_feature').should == false
    end
  end

  describe 'percentable' do

    before do
      @feature = Trebuchet.feature("liberty")
      @user = User.new(0)
      @request = mock_request('abcdef')
      @trebuchet = Trebuchet.new(@user, @request)
    end

    it "should use from and to" do
      @feature.aim(:visitor_percent_deprecated, :from => 5, :to => 10)
      Trebuchet.feature("liberty").strategy.offset.should == 0
      Trebuchet.visitor_id = 10
      Trebuchet.feature("liberty").launch_at?(@user, @request).should == true
      Trebuchet.visitor_id = 5
      Trebuchet.feature("liberty").launch_at?(@user, @request).should == true
      Trebuchet.visitor_id = 4
      Trebuchet.feature("liberty").launch_at?(@user, @request).should == false
      Trebuchet.visitor_id = 11
      Trebuchet.feature("liberty").launch_at?(@user, @request).should == false
    end

    it "should use a percentage" do
      @feature.aim(:visitor_percent_deprecated, :percentage => 25)
      offset = @feature.strategy.offset
      offset.should == 90
      Trebuchet.visitor_id = 24 + offset
      Trebuchet.feature("liberty").launch_at?(@user, @request).should == true
      Trebuchet.visitor_id = 0 + offset
      Trebuchet.feature("liberty").launch_at?(@user, @request).should == true
      Trebuchet.visitor_id = 5 + offset
      Trebuchet.feature("liberty").launch_at?(@user, @request).should == true
      Trebuchet.visitor_id = 25 + offset
      Trebuchet.feature("liberty").launch_at?(@user, @request).should == false
    end

  end

end
