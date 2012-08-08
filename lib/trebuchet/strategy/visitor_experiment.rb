class Trebuchet::Strategy::VisitorExperiment < Trebuchet::Strategy::Base

  include Trebuchet::Strategy::Experimentable

  def initialize(options = {})
    initialize_experiment(options)
  end

  def launch_at?(user, request = nil)
   if Trebuchet.visitor_id.respond_to?(:call)
      visitor_id = Trebuchet.visitor_id.call(request)
    else
      visitor_id = nil
    end
    return false if visitor_id.nil?
    value_in_bucket?(visitor_id)
  end

  def needs_user?
    false
  end

end