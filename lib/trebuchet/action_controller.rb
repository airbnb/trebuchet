module Trebuchet::ActionController

  def self.included(base)
    base.helper_method :trebuchet
  end

  def trebuchet
    @trebuchet ||= Trebuchet.new(current_user, request)
  end

end
