module Trebuchet::ActionController

  def self.included(base)
    base.helper_method :trebuchet
  end

  def trebuchet
    Trebuchet.initialize_logs
    @trebuchet ||= Trebuchet.new(current_user, request)
  end

end
