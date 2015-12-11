class Trebuchet::ActionControllerFilter

  def self.before(controller)
    Trebuchet.initialize_logs

    if Trebuchet.backend.respond_to?(:refresh)
      Trebuchet.backend.refresh
    end

    Trebuchet.current_block = Proc.new {
      Trebuchet.new(controller.send(:current_user), controller.request)
    }
  end

  def self.after(controller)
    Trebuchet.current_block = nil
    Trebuchet.reset_current! # very important
  end

end
