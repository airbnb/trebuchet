class Trebuchet::Strategy::Percent < Trebuchet::Strategy::Base

  include Trebuchet::Strategy::Percentable
  
  def initialize(options)
    set_range_from_options(options)
    if @legacy = options.is_a?(Numeric)  # TODO: remove once fully tested
      @percentage = options.to_i
    end
  end
  
  def launch_at?(user, request = nil)
    return false unless user && user.id
    return !!((user.id + offset) % 100 < @percentage) if @legacy # TODO: remove once fully tested
    value_in_range?(user.id.to_i)
  end

  # def to_s from percentable

end