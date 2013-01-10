require 'spec_helper'

describe Trebuchet::Feature do
  
  def feature
    Trebuchet.feature('some_feature')
  end

  def feature_names
    Trebuchet.backend.get_feature_names
  end

  def archived_feature_names
    Trebuchet.backend.get_archived_feature_names
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
  
  describe :augment do
    
    it "should add one strategy where none exist" do
      feature.dismantle
      feature.augment(:percent, 10)
      feature.strategy.name.should be :percent
    end
    
    it "should append a strategy if others exist" do
      feature.aim(:percent, 10)
      feature.augment(:users, 1)
      feature.strategy.name.should be :multiple
      percent_strategy = feature.strategy.strategies.detect { |s| s.name == :percent }
      percent_strategy.percentage.should == 10
      user_strategy = feature.strategy.strategies.detect { |s| s.name == :users }
      user_strategy.user_ids.should include(1)
    end
    
    it "should adjust an existing strategy with numeric" do
      feature.aim(:percent, 10)
      feature.augment(:percent, 5)
      feature.strategy.name.should be :percent
      feature.strategy.percentage.should be 15
      feature.augment(:percent, 5.0)
      feature.strategy.percentage.should be 20
    end
    
    it "should adjust an existing strategy with set/array" do
      feature.aim(:users, [1])
      feature.augment(:users, [2,3])
      feature.strategy.name.should == :users
      feature.strategy.user_ids.sort.should == [1,2,3]
      feature.augment(:users, [4])
      feature.strategy.user_ids.sort.should == [1,2,3,4]
      # this probably should not be allowed
      # feature.aim(:users, 1)
      # feature.augment(:users, 2)
      # feature.strategy.user_ids.sort.should == [1,2]
    end
    
    it "should adjust an existing strategy with hash" do
      Trebuchet.define_strategy(:role_percent) do |user, options|
        percent = options[user.role].to_i
        user.id % 100 < percent
      end
      old_percentages = {:admin => 30, :editor => 50, :publisher => 100}
      feature.aim(:role_percent, old_percentages)
      new_percentages = {:admin => 100, :reviewer => 10}
      feature.augment(:role_percent, new_percentages)
      feature.strategy.name.should be :custom
      feature.strategy.custom_name.should be :role_percent
      feature.strategy.options.should == (old_percentages.merge(new_percentages))
    end
    
  end

  describe :dismantle do

    it "should remove a feature and add it to archived features" do
      feature.aim(:users, [1])
      feature_names.include?(feature.name).should be_true
      feature.dismantle
      feature_names.include?(feature.name).should be_false
      archived_feature_names.include?(feature.name).should be_true
    end

    it "should remove archived feature when dismantled feature is redefined" do
      feature.dismantle
      feature_names.include?(feature.name).should be_false
      archived_feature_names.include?(feature.name).should be_true
      feature.aim(:percent, 5)
      feature_names.include?(feature.name).should be_true
      archived_feature_names.include?(feature.name).should be_false
    end

  end

end
