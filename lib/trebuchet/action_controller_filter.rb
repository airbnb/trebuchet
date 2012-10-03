class Trebuchet::ActionControllerFilter

  def self.before(controller)
    Trebuchet.initialize_logs
    
    if Trebuchet.backend.is_a?(Trebuchet::Backend::RedisCached) && Trebuchet.backend.respond_to?(:clear_cached_strategies)
      if Time.now > Trebuchet.backend.cache_cleared_at + 60.seconds
        Trebuchet.backend.clear_cached_strategies 
      end
    end
    
    Trebuchet.current = Proc.new { Trebuchet.new controller.send(:current_user), controller.request }
  end

  def self.after(controller)
  	Trebuchet.current = nil # very important
  end

end
