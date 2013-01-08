class Trebuchet::Strategy::UserId < Trebuchet::Strategy::Base

  attr_reader :user_ids

  def initialize(user_ids)
    user_ids = Array(user_ids).flatten
    @user_ids = Set.new(user_ids)
  end

  def launch_at?(user, request = nil)
    @user_ids.include?(user.id)
  end

  def to_s
    "user ids (#{user_ids.empty? ? 'none' : user_ids.to_a.join(', ')})"
  end

end