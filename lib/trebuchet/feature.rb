class Trebuchet::Feature

  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def self.find(name)
    new(name)
  end
  
  def self.all
    Trebuchet.backend.get_feature_names.map{|name| new(name)}
  end
  
  def self.dismantled
    Trebuchet.backend.get_archived_feature_names.map{|name| new(name)}
  end
  
  def self.exist?(name)
    !!all.detect{|feature| feature.name == name }
  end

  def strategy
    Trebuchet::Strategy.for_feature(self)
  end
  
  def valid?
    strategy.name != :invalid
  end

  def launch_at?(user, request = nil)
    (!strategy.needs_user? || !user.nil?) && strategy.launch_at?(user, request)
  end

  def aim(strategy_name, options = nil)
    if chained?
      Trebuchet.backend.append_strategy(self.name, strategy_name, options)
    else
      Trebuchet.backend.set_strategy(self.name, strategy_name, options)
    end
    @chained = true
    self
  end
  
  # add/edit just one strategy without affecting other chained strategies
  def adjust(strategy_name, options = nil)
    Trebuchet.backend.append_strategy(self.name, strategy_name, options)
    self
  end
  
  # add to the options of a strategy (if it is an integer, hash or array)
  def augment(strategy_name, options)
    # get old args if any
    # augment them carefully
    # adjust that strategy
  end
  
  def dismantle
    Trebuchet.backend.remove_feature(self.name)
  end
  
  def as_json(options = {})
    {:name => @name, :strategy => strategy}
  end

  private

  def chained?
    @chained
  end

end
