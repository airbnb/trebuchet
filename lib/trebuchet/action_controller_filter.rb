class Trebuchet::ActionControllerFilter

  def self.before(controller)
    Trebuchet.initialize_logs
  end

  def self.after(controller)
  end

end
