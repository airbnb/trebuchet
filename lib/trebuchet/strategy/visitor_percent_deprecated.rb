class Trebuchet::Strategy::VisitorPercentDeprecated < Trebuchet::Strategy::Base

  include Trebuchet::Strategy::PercentableDeprecated

  def initialize(options)
    set_range_from_options(options)
  end

  def launch_at?(user, request = nil)
    return false if request.nil?
    if Trebuchet.visitor_id.respond_to?(:call)
      visitor_id = Trebuchet.visitor_id.call(request)
    else
      visitor_id = nil
    end
    return false if visitor_id.nil?
    value_in_range?(visitor_id.to_i)
  end

  def needs_user?
    false
  end

  # def to_s from percentable

end

