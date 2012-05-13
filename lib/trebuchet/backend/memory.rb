class Trebuchet::Backend::Memory

  def initialize(*args)
    @hash = {}
    @archived = []
  end

  def get_strategy(feature_name)
    @hash.fetch(feature_name, nil) || []
  end

  def set_strategy(feature, strategy, options = nil)
    @hash.store(feature, [strategy, options])
  end

  def append_strategy(feature, strategy, options = nil)
    strategies = get_strategy(feature) || []
    if i = strategies.index(strategy)
      strategies.delete_at(i) # remove strategy_name
      strategies.delete_at(i) # remove options
    end
    strategies += [strategy, options]
    @hash.store(feature, strategies)
  end
  
  def remove_strategy(feature)
    @hash.delete(feature)
  end
  
  def get_feature_names
    @hash.keys
  end
  
  def remove_feature(feature)
    @hash.delete(feature)
    @archived << feature
  end
  
  def get_archived_feature_names
    @archived
  end

end
