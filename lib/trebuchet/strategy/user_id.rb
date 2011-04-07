class Trebuchet::Strategy::UserId

  attr_reader :user_ids

  def initialize(user_ids)
    @user_ids = Set.new(user_ids)
  end

  def launch_at?(user)
    @user_ids.include?(user.id)
  end

end
