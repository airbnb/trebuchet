class Trebuchet::Strategy::Hostname < Trebuchet::Strategy::Base

  attr_reader :hostnames

  def initialize(hostnames)
    @hostnames = if hostnames.is_a?(Array)
      hostnames
    else
      [hostnames]
    end
  end

  def launch_at?(user, request = nil)
    return false if request.nil?
    self.hostnames.include?(request.host)
  end

  def needs_user?
    false
  end

  def to_s
    "hostnames (#{hostnames.empty? ? 'none' : hostnames.join(', ')})"
  end

end
