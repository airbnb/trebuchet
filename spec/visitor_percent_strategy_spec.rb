require 'spec_helper'

describe Trebuchet::Strategy::VisitorPercent do

  it "should not break if no visitor id is set" do
    Trebuchet.aim('some_feature', :visitor_percent, 100)
    t = Trebuchet.new(User.new(0))
    t.launch?('some_feature').should == false
  end
  
  it "should require a request" do
    Trebuchet.visitor_id = 1
    Trebuchet.aim('some_feature', :visitor_percent, 100)
    t = Trebuchet.new(User.new(1), nil)
    t.launch?('some_feature').should == false
  end

  it "should not require a user" do
    Trebuchet.visitor_id = 1
    Trebuchet.aim('some_feature', :visitor_percent, 100)
    t = Trebuchet.new(nil, mock_request('12345'))
    t.launch?('some_feature').should == true
  end

  describe 'visitor id integer' do
    before do
      Trebuchet.visitor_id = 123
    end

    it 'should launch' do
      # offset of some_feature is 33
      Trebuchet.aim('some_feature', :visitor_percent, 100)
      t = Trebuchet.new(User.new(0), mock_request('12345'))
      t.launch?('some_feature').should == true

      Trebuchet.aim('some_feature', :visitor_percent, 57)
      t.launch?('some_feature').should == true

      Trebuchet.aim('some_feature', :visitor_percent, 56)
      t.launch?('some_feature').should == false
    end
  end

  describe 'visitor id proc' do
    before do
      Trebuchet.visitor_id = proc { |request| request && request.cookies[:visitor] && request.cookies[:visitor].hash }
    end

    it 'should not launch if no request is present' do
      Trebuchet.aim('some_feature', :visitor_percent, 100)
      should_not_launch('some_feature', [1000])
    end

    it 'should launch to a valid session' do
      Trebuchet.aim('some_feature', :visitor_percent, 100)
      t = Trebuchet.new(User.new(0), mock_request('abcdef'))
      t.launch?('some_feature').should == true
    end

    it 'should not launch to a nil session ID' do
      Trebuchet.aim('some_feature', :visitor_percent, 100)
      t = Trebuchet.new(User.new(0), mock_request(nil))
      t.launch?('some_feature').should == false
    end
  end

  describe 'visitor id invalid' do
    it "should handle nil" do
      Trebuchet.visitor_id = nil
      Trebuchet.aim('some_feature', :visitor_percent, 100)
      t = Trebuchet.new(User.new(0), mock_request('abcdef'))
      t.launch?('some_feature').should == false
    end
  end

  def mock_request(cookie = nil)
    mock 'Request', :cookies => {:visitor => cookie}
  end

end
