require 'spec_helper'

describe Trebuchet::Feature::Stubbing do

  before do
    Trebuchet.dismantle_stubs
  end

  describe '#stub' do

    it "should stub a feature as launched" do
      Trebuchet.feature('test').stub(:launched)
      should_launch('test', [0])
    end

    it "should stub a feature as not launched" do
      Trebuchet.feature('test').stub(:not_launched)
      should_not_launch('test', [0])
    end

    it "should employ the stub strategy for features stubbed launched" do
      Trebuchet.feature('test').stub(:launched)
      Trebuchet.feature('test').strategy.is_a?(Trebuchet::Strategy::Stub)
    end

    it "should employ the stub strategy for features stubbed not launched" do
      Trebuchet.feature('test').stub(:not_launched)
      Trebuchet.feature('test').strategy.is_a?(Trebuchet::Strategy::Stub)
    end

  end

  describe '#stubbed?' do

    it "should report when features are stubbed launched" do
      Trebuchet.feature('test').stub(:launched)
      Trebuchet.feature('test').should be_stubbed
    end

    it "should report when features are stubbed not launched" do
      Trebuchet.feature('test').stub(:not_launched)
      Trebuchet.feature('test').should be_stubbed
    end

  end

  describe '#dismantle_stubs' do

    it "should reset stubbed features" do
      Trebuchet.feature('test').stub(:launched)
      Trebuchet.dismantle_stubs
      Trebuchet::Feature.stubbed_features.should be_empty
    end

    it "should restore them to their default state" do
      Trebuchet.feature('test').stub(:launched)
      Trebuchet.dismantle_stubs
      should_not_launch('test', [0])
    end

  end

  describe '#stubbed_features' do

    it "should report when feature are stubbed" do
      Trebuchet.feature('test').stub(:launched)
      Trebuchet::Feature.stubbed_features.count.should == 1
    end

    it "should report when features are stubbed launched" do
      Trebuchet.feature('test').stub(:launched)
      Trebuchet::Feature.stubbed_features['test'].should == :launched
    end

    it "should report when features are stubbed not launched" do
      Trebuchet.feature('test').stub(:not_launched)
      Trebuchet::Feature.stubbed_features['test'].should == :not_launched
    end

  end

end