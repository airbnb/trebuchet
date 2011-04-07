class Trebuchet::Strategy::Percentage

  attr_reader :percentage

  def initialize(percentage)
    @percentage = percentage
  end

  def launch_at?(user)
    user.id % (100 / percentage) == 0
  end

end
