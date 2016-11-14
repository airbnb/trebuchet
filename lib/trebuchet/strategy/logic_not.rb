require 'trebuchet/strategy/logic_base'

class Trebuchet::Strategy::LogicNot < Trebuchet::Strategy::LogicBase

  def launch_at?(user, request = nil)
    @strategies
      .none? { |s| (!s.needs_user? || !user.nil?) && s.launch_at?(user, request) }
  end

end