require 'singleton'
# Everyone is to launch the feature to everyone
class Trebuchet::Strategy::Everyone < Trebuchet::Strategy::Base
  include Singleton

  def initialize(options = nil)
    # ignore options
  end

  def name
    :everyone
  end

  def launch_at?(user, request = nil)
    true
  end

  def needs_user?
    false
  end

  def to_s
    "launched to everyone"
  end

end
