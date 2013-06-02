class Trebuchet::Strategy::Percent < Trebuchet::Strategy::Base

  include Trebuchet::Strategy::Percentable
  
  def initialize(options)
    set_range_from_options(options)
  end
  
  def launch_at?(user, request = nil)
    return false unless user && user.id
    value_in_range?(user.id.to_i)
  end

  # def to_s from percentable
  
  # def export from percentable

end