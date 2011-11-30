require 'spec_helper'

describe Trebuchet::Backend::Disabled do
  
  before do
    Trebuchet.backend = :disabled
    Trebuchet.backend.should be_a(Trebuchet::Backend::Disabled)
  end

  it "should not store features" do
    Trebuchet.feature('thing').aim(:users, [5]).aim(:percent, 9)
    Trebuchet.feature('thing').strategy.should be_a(Trebuchet::Strategy::Default)
    Trebuchet::Feature.all.should eql []
  end
  
  after do
    Trebuchet.backend = :memory
  end
 

end
