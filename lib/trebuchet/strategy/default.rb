# Default is to not launch the feature to anyone
class Trebuchet::Strategy::Default < Trebuchet::Strategy::Base

  def initialize(options = nil)
    # ignore options
  end
  
  def name
    :default
  end

  def launch_at?(user, request = nil)
    false
  end
  
  def needs_user?
    false
  end

  def to_s
    "not launched (default)"
  end
  
end
