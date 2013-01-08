class Trebuchet::Strategy::VisitorPercent < Trebuchet::Strategy::Base

  include Trebuchet::Strategy::Percentable

  def initialize(options)
    set_range_from_options(options)
    if @legacy = options.is_a?(Numeric)  # TODO: remove once fully tested
      @percentage = options.to_i
    end
  end

  def launch_at?(user, request = nil)
    return false if request.nil?
    if Trebuchet.visitor_id.respond_to?(:call)
      visitor_id = Trebuchet.visitor_id.call(request)
    else
      visitor_id = nil
    end
    return false if visitor_id.nil?
    
    return !!((visitor_id + offset) % 100 < @percentage) if @legacy  # TODO: remove once fully tested
    value_in_range?(visitor_id.to_i)
  end

  def needs_user?
    false
  end

  # def to_s from percentable

end
