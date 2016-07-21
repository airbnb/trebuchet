require 'trebuchet/strategy/logic_base'

class Trebuchet::Strategy::LogicOr < Trebuchet::Strategy::LogicBase

  def launch_at?(user, request = nil)
    @strategies
      .select { |s| !user.nil? || !s.needs_user? }
      .any? { |s| s.launch_at?(user, request) }
  end

end