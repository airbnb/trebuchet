class TrebuchetController < ApplicationController
  
  before_filter :control_access

  def index
    @features = Trebuchet::Feature.all
    @features.sort! {|x,y| x.name.downcase <=> y.name.downcase }
    
    @dismantled_features = Trebuchet::Feature.dismantled
    @dismantled_features.sort! {|x,y| x.name.downcase <=> y.name.downcase }
    
    respond_to do |wants|
      wants.html # index.html.erb
      wants.json { render :json => @features }
    end
  end
  
  private
  def control_access
    allowed = if Trebuchet.admin_view.is_a?(Proc)
      begin
        instance_eval &(Trebuchet.admin_view)
      rescue
        false
      end
    else
      !!Trebuchet.admin_view
    end
    raise ActionController::RoutingError.new('Not Found') unless allowed
  end
  
end
