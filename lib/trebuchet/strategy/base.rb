require 'digest/sha1'

class Trebuchet::Strategy::Base
  
  attr_accessor :feature
  
  def name
    self.class.strategy_name
  end
  
  def feature_id
    Digest::SHA1.hexdigest(@feature.name).to_i(16)
  rescue
    return 0
  end

  def needs_user?
    true
  end

  def self.strategy_name
    Trebuchet::Strategy.name_for_class(self)
  end
  
  def as_json(options = {})
    excluded = [:feature, :block]
    {:name => name}.tap do |h|
      instance_variables.map do |v|
        key = v.gsub('@','').to_sym
        h[key] = instance_variable_get(v) unless excluded.include?(key)
      end
    end
  end
  
end
