# require 'digest/sha1'

class Trebuchet::Strategy::Experiment < Trebuchet::Strategy::Base
  
  include Trebuchet::Strategy::Experimentable  

  def initialize(options = {})
    initialize_experiment(options)
  end

  def launch_at?(user, request = nil)
    return false unless user && user.id
    value_in_bucket?(user.id)
  end

  # def to_s from experimentable

  # def export from experimentable

end