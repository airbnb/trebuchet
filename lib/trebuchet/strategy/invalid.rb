# Default is to not launch the feature to anyone
class Trebuchet::Strategy::Invalid < Trebuchet::Strategy::Base

  attr_reader :invalid_name, :options

  def initialize(name, options = nil)
    @invalid_name = name
    @options = options
  end

  def name
    :invalid
  end

  def launch_at?(user, request = nil)
    false
  end
  
end