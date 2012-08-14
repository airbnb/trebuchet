module Trebuchet::ActionController

  def self.included(base)
    base.helper_method :trebuchet
    base.class_eval do
      around_filter Trebuchet::ActionControllerFilter
    end
  end

  def trebuchet
    @trebuchet ||= Trebuchet.new(current_user, request)
  end

end
