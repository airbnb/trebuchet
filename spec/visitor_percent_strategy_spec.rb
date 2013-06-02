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
      offset = Trebuchet.feature('some_feature').strategy.offset
      t = Trebuchet.new(User.new(0), mock_request('12345'))
      t.launch?('some_feature').should == true
      visitor_id = Trebuchet.visitor_id.call

      Trebuchet.aim('some_feature', :visitor_percent, 91) # 33 + 91 includes 123 % 100
      t.launch?('some_feature').should == true

      Trebuchet.aim('some_feature', :visitor_percent, 90)
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
  
  describe 'percentable' do
    
    before do
      @feature = Trebuchet.feature("liberty")
      @trebuchet = Trebuchet.new(User.new(0), mock_request('abcdef'))
    end
    
    it "should use from and to" do
      @feature.aim(:visitor_percent, :from => 5, :to => 10)
      Trebuchet.feature("liberty").strategy.offset.should == 0
      Trebuchet.visitor_id = 10
      @trebuchet.launch?("liberty").should == true
      Trebuchet.visitor_id = 5
      @trebuchet.launch?("liberty").should == true
      Trebuchet.visitor_id = 4
      @trebuchet.launch?("liberty").should == false
      Trebuchet.visitor_id = 11
      @trebuchet.launch?("liberty").should == false
    end
    
    it "should use a percentage" do
      @feature.aim(:visitor_percent, :percentage => 25)
      offset = @feature.strategy.offset
      offset.should == 90
      Trebuchet.visitor_id = 24 + offset
      @trebuchet.launch?("liberty").should == true
      Trebuchet.visitor_id = 0 + offset
      @trebuchet.launch?("liberty").should == true
      Trebuchet.visitor_id = 5 + offset
      @trebuchet.launch?("liberty").should == true
      Trebuchet.visitor_id = 25 + offset
      @trebuchet.launch?("liberty").should == false
    end
    
  end

end
