require 'singleton'
# Nobody is to launch the feature to nobody
class Trebuchet::Strategy::Nobody < Trebuchet::Strategy::Base
  include Singleton

  def initialize(options = nil)
    # ignore options
  end

  def name
    :nobody
  end

  def launch_at?(user, request = nil)
    false
  end

  def needs_user?
    false
  end

  def to_s
    "nobody (nobody)"
  end

end
