class Trebuchet::Strategy::VisitorPercent < Trebuchet::Strategy::Base

  attr_reader :percentage

  def initialize(percentage)
    @percentage = percentage
  end

  def offset
    feature_id % 100
  end

  def launch_at?(user, request = nil)
    return false if request.nil?
    if Trebuchet.visitor_id.respond_to?(:call)
      visitor_id = Trebuchet.visitor_id.call(request)
    else
      visitor_id = nil
    end

    return false if visitor_id.nil?
    (visitor_id + offset) % 100 < percentage
  end

  def needs_user?
    false
  end

end
