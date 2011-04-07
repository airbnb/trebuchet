module Trebuchet
  module ActionController
    def self.included(base)
      base.helper_method :trebuchet
    end

    def trebuchet
      @trebuchet ||= Trebuchet.new(current_user, request)
    end
  end
end

ActionController::Base.send(:include, Trebuchet::ActionController)
