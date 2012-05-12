require 'spec_helper'

describe Trebuchet::Feature do
  
  def feature
    Trebuchet.feature('some_feature')
  end
  
  describe :aim do
    
    it "should add one strategy" do
      feature.aim(:percent, 10)
      feature.strategy.name.should be :percent
    end
    
    it "should add multiple strategies by chaining" do
      feature.aim(:default)
      feature.strategy.name.should be :default
      feature.aim(:percent, 10).aim(:users, 1)
      feature.strategy.name.should be :multiple
      strategy_names = feature.strategy.strategies.map{ |s| s.name }
      strategy_names.should include(:percent)
      strategy_names.should include(:users)
    end
    
    it "should obliterate chained strategies" do
      feature.aim(:percent, 10).aim(:users, 1)
      feature.aim(:default)
      feature.strategy.name.should be :default
    end
    
  end
  
  describe :adjust do
    
    it "should add one strategy" do
      feature.dismantle
      feature.adjust(:percent, 10)
      feature.strategy.name.should be :percent
    end
    
    it "should adjust a strategy in the chain" do
      feature.aim(:percent, 10).aim(:users, 1)
      feature.strategy.name.should be :multiple
      feature.adjust(:users, 2)
      feature.strategy.name.should be :multiple
      user_strategy = feature.strategy.strategies.detect { |s| s.name == :users }
      user_strategy.user_ids.should include(2)
      user_strategy.user_ids.should_not include(1)
      feature.adjust(:percent, 20)
      percent_strategy = feature.strategy.strategies.detect { |s| s.name == :percent }
      percent_strategy.percentage.should == 20
    end
    
    it "should not obliterate chained strategies" do
      feature.aim(:percent, 10).aim(:users, 1)
      feature.adjust(:default)
      feature.strategy.name.should be :multiple
      feature.strategy.strategies.map{ |s| s.name }.should include(:default)
    end
    
  end

end
