module TrebuchetRails
  
  class FeaturesController < ApplicationController
  
    before_filter :control_access, :get_time_zone

    layout 'trebuchet'
    helper :trebuchet

    def index
      @features = Trebuchet::Feature.all
      @features.sort! {|x,y| x.name.downcase <=> y.name.downcase }
      
      @dismantled_features = Trebuchet::Feature.dismantled
      @dismantled_features.sort! {|x,y| x.name.downcase <=> y.name.downcase }
      
      respond_to do |wants|
        wants.html # index.html.erb
        wants.json { render :json => @features.map(&:export) }
      end
    end
    
    def timeline
      @history = []
      Trebuchet::Feature.all.each do |f|
        f.history.each do |timestamp, strategy|
          @history << { 
            :feature_name => f.name, 
            :timestamp => timestamp, 
            :strategy => strategy
          }
        end
      end
      @history = @history.sort_by { |h| h[:timestamp] }
      @history.reverse!
      respond_to do |wants|
        wants.html # index.html.erb
        wants.json do
           json_history = @history.map do |history|
            history.tap { |h| h[:strategy] = h[:strategy].export }
          end
          render :json => json_history
        end
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
    
    def get_time_zone
      @zone = if Trebuchet.time_zone
        if Trebuchet.time_zone.is_a?(Proc)
          Trebuchet.time_zone.call
        elsif Trebuchet.time_zone.is_a?(String)
          Trebuchet.time_zone
        else
          nil
        end
      end
      @zone = ActiveSupport::TimeZone.new(@zone || 'UTC')
    end
    
  end

end
