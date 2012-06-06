class Trebuchet::Strategy::Hostname < Trebuchet::Strategy::Base

  attr_reader :hostname

  def initialize(hostname)
    @hostname = if hostname.is_a?(Array)
      hostname
    else
      [hostname]
    end
  end

  def launch_at?(user, request = nil)
    return false if request.nil?
    self.hostname.include?(request.host)
  end

  def needs_user?
    false
  end

end
