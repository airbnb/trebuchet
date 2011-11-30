# Default is to not launch the feature to anyone
class Trebuchet::Strategy::Default < Trebuchet::Strategy::Base

  def initialize(options = nil)
    # ignore options
  end
  
  def name
    :default
  end

  def launch_at?(user)
    false
  end
  
end
