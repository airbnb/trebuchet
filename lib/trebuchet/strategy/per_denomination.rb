class Trebuchet::Strategy::PerDenomination < Trebuchet::Strategy::Base
  include Trebuchet::Strategy::PerDenominationable

  def set_range_from_options(options = {})
    numerator = options['numerator'] || options[:numerator] || 0
    denominator = options['denominator'] || options[:denominator] || 0

    super(numerator: numerator, denominator: denominator)
  end

  def launch_at?(user, request = nil)
    return false unless user && user.id
    value_in_range?(user.id.to_i)
  end

  # def to_s from PerDenominationable

  # def export from PerDenominationable
end
