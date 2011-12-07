class Trebuchet::Strategy::Percentage < Trebuchet::Strategy::Base

  attr_reader :percentage

  def initialize(percentage)
    @percentage = percentage
  end
  
  def offset
    feature_id % 100
  end

  def launch_at?(user)
    (user.id + offset) % 100 < percentage
  end

end
