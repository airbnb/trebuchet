# Default is to not launch the feature to anyone
class Trebuchet::Strategy::Default

  def launch_at?(user)
    false
  end

end
