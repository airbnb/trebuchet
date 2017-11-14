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

    it "caches value of launch_at?" do
      t = Trebuchet.new(nil)
      Trebuchet.feature('highly_experimental').should_receive(:launch_at?).once
      Trebuchet.feature('waste_of_time').should_receive(:launch_at?).once

      t.launch?('highly_experimental')
      t.launch?('waste_of_time')

      t.launch?('highly_experimental')
      t.launch?('waste_of_time')
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
  
  describe "logging" do
    
    before(:all) do
      Trebuchet.aim('highly_experimental', :users, [1,2])
      Trebuchet.aim('disused', :disabled)
    end
    
    before(:each) do
      Trebuchet.initialize_logs
    end
    
    it "should log" do
      Trebuchet.logs.should == {}
      Trebuchet.new(User.new(1)).launch?('highly_experimental').should == true
      Trebuchet.logs['highly_experimental'].should == true
    end
    
    it "should log false/nil" do
      Trebuchet.logs['complely_fabricated'] == nil
      Trebuchet.logs['disused'].should == nil
      Trebuchet.new(User.new(1)).launch?('disused') #.should == false
      Trebuchet.logs['disused'].should == false
    end
    
    it "it should clear logs" do
      Trebuchet.new(User.new(1)).launch?('highly_experimental').should == true
      Trebuchet.logs['highly_experimental'].should == true
      Trebuchet.initialize_logs
      Trebuchet.logs.should == {}
    end
    
    it "should log from multiple trebuchet instances" do
      Trebuchet.new(User.new(1)).launch?('highly_experimental') #.should == true
      Trebuchet.new(User.new(1)).launch?('disused') #.should == false
      Trebuchet.new(nil).launch?('waste_of_time') #.should == false
      Trebuchet.logs['highly_experimental'].should == true
      Trebuchet.logs['disused'].should == false
      Trebuchet.logs['waste_of_time'].should == false
    end
    
  end

  describe "exception handling" do

    before :all do
      class BoomError < StandardError ; end
      Trebuchet.define_strategy(:boom) do
        raise BoomError.new "BOOM!"
      end
      Trebuchet.aim('optimism', :boom)
    end

    it "should swallow exceptions if no exception_handler defined" do
      expect { Trebuchet.current.launch?("optimism") }.to_not raise_exception
    end

    it "should invoke exception_handler if defined" do
      @feature = nil
      @exception = nil
      Trebuchet.exception_handler = lambda { |e, f, t| @exception = e; @feature = f }
      Trebuchet.current.launch?("optimism")
      @exception.should_not be_nil
      @feature.should == 'optimism'
    end

    it "should allow exception_handler to raise the exception" do
      Trebuchet.exception_handler = lambda { |e, f, t| raise e } # useful in development
      expect { Trebuchet.current.launch?("optimism") }.to raise_exception(BoomError)
    end

    it "should accept 0 to 3 arguments" do
      Trebuchet.exception_handler = lambda { @last_arg = eval local_variables.last.to_s }
      Trebuchet.current.launch?("optimism")
      @last_arg.should == nil
      
      Trebuchet.exception_handler = lambda { |e| @last_arg = eval local_variables.last.to_s  }
      Trebuchet.current.launch?("optimism")
      @last_arg.should be_a(StandardError)

      Trebuchet.exception_handler = lambda { |e, f| @last_arg = eval local_variables.last.to_s  }
      Trebuchet.current.launch?("optimism")
      @last_arg.should == "optimism"

      Trebuchet.exception_handler = lambda { |e, f, t| @last_arg = eval local_variables.last.to_s  }
      Trebuchet.current.launch?("optimism")
      @last_arg.should be_a(Trebuchet)

      Trebuchet.exception_handler = lambda { |*args| @args = args }
      Trebuchet.current.launch?("optimism")
      @args.size.should == 3
      @args.last.should be_a(Trebuchet)
    end

    it "should not blow up if exception_handler is not a proc" do
      Trebuchet.exception_handler = "one of my shoes"
      expect { Trebuchet.current.launch?("optimism") }.to_not raise_exception

      Trebuchet.exception_handler = false
      expect { Trebuchet.current.launch?("optimism") }.to_not raise_exception

      Trebuchet.exception_handler = true
      expect { Trebuchet.current.launch?("optimism") }.to_not raise_exception

      Trebuchet.exception_handler = Trebuchet.current
      expect { Trebuchet.current.launch?("optimism") }.to_not raise_exception
    end

  end
  
end
