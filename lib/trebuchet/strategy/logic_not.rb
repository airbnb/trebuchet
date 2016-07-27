require 'trebuchet/strategy/logic_base'

class Trebuchet::Strategy::LogicNot < Trebuchet::Strategy::LogicBase

  def launch_at?(user, request = nil)
    @strategies
      .select { |s| !user.nil? || !s.needs_user? }
      .none? { |s| s.launch_at?(user, request) }
  end

end