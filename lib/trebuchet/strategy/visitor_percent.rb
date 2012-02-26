class Trebuchet::Strategy::VisitorPercent < Trebuchet::Strategy::Base

  attr_reader :percent

  def initialize(percent)
    @percent = percent
  end

  def offset
    feature_id % 100
  end

  def launch_at?(user, request = nil)
    if Trebuchet.visitor_id.respond_to?(:call)
      visitor_id = Trebuchet.visitor_id.call(request)
    else
      visitor_id = nil
    end

    return false if visitor_id.nil?
    (visitor_id + offset) % 100 < percent
  end

  def needs_user?
    false
  end

end
