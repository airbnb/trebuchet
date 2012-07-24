require 'spec_helper'

describe Trebuchet do
  
  describe "launch?" do
    
    it "should call launch_at? on feature" do
      Trebuchet::Feature.any_instance.should_receive(:launch_at?).once
      Trebuchet.new(User.new(1)).launch?('highly_experimental')
    end
  
    it "should  call launch_at? on feature even if missing user" do
      Trebuchet::Feature.any_instance.should_receive(:launch_at?).once
      Trebuchet.new(nil).launch?('highly_experimental')
    end
    
  end
    
  describe "launch" do
    it "should execute a block" do
      times = 0
      Trebuchet.aim('highly_experimental', :users, [1,2])
      (Trebuchet.new(User.new(1)).launch('highly_experimental') { times += 1 }).should be_true
      (Trebuchet.new(User.new(3)).launch('highly_experimental') { times += 1 }).should be_false
      times.should == 1
    end
    
    it "should not blow up if block is missing" do
      lambda do
        Trebuchet.aim('highly_experimental', :users, [1,2])
        Trebuchet.new(User.new(1)).launch('highly_experimental').should be_true
        Trebuchet.new(User.new(3)).launch('highly_experimental').should be_false
        Trebuchet.new(nil).launch('highly_experimental').should be_false
      end.should_not raise_error(LocalJumpError)
      
    end
    
  end
  
end