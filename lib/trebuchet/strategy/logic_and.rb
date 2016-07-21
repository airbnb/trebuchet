require 'trebuchet/strategy/logic_base'

class Trebuchet::Strategy::LogicAnd < Trebuchet::Strategy::LogicBase

  def launch_at?(user, request = nil)
    @strategies
      .select { |s| !user.nil? || !s.needs_user? }
      .all? { |s| s.launch_at?(user, request) }
  end

end