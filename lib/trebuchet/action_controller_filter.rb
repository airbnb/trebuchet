class Trebuchet::ActionControllerFilter

  def self.before(controller)
    Trebuchet.initialize_logs
    Trebuchet.current = Proc.new { Trebuchet.new controller.send(:current_user), controller.request }
  end

  def self.after(controller)
  	Trebuchet.current = nil # very important
  end

end
