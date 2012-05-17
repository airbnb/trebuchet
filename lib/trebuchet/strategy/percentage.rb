class Trebuchet::Strategy::Percentage < Trebuchet::Strategy::Base

  attr_reader :percentage

  def initialize(percentage)
    @percentage = percentage.to_i
  end
  
  def offset
    feature_id % 100
  end

  def launch_at?(user, request = nil)
    if user.nil? || user.id.nil? # catch unsaved user
      false
    else
      (user.id + offset) % 100 < percentage
    end
  end
  
end
