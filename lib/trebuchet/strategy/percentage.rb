class Trebuchet::Strategy::Percentage < Trebuchet::Strategy::Base

  attr_reader :percentage

  def initialize(percentage)
    @percentage = percentage
  end
  
  def offset
    if feature
      # arbitrary yet deterministic offset based on feature name to vary the test groups
      feature.name.hash % 100
    else
      0
    end
  end

  def launch_at?(user)
    (user.id + offset) % 100 < percentage
  end

end
