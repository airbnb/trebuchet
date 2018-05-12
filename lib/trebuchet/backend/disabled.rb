# This backend stores nothing and returns empty/false data (launch? will always be false)
# It can be used to disable all Trebuchet features (especially if Trebuchet fails to connect to it's normal data store)

class Trebuchet::Backend::Disabled

  def initialize(*args)
  end

  def get_strategy(feature_name)
    [:default]
  end

  def set_strategy(feature, strategy, options = nil, force = false)
    false
  end

  def append_strategy(feature, strategy, options = nil, force = false)
    false
  end
  
  def get_feature_names
    []
  end

end
