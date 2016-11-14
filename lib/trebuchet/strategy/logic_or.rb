require 'trebuchet/strategy/logic_base'

class Trebuchet::Strategy::LogicOr < Trebuchet::Strategy::LogicBase

  def launch_at?(user, request = nil)
    @strategies
      .any? { |s| (!s.needs_user? || !user.nil?) && s.launch_at?(user, request) }
  end

end