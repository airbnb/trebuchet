require 'trebuchet/feature/stubbing'

class Trebuchet::Feature
  include Stubbing

  @@deprecated_strategies_enabled = true
  @@features = {}

  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def self.find(name)
    feature = @@features[name]
    if !feature
      feature = new(name)
      @@features[name] = feature
    end

    feature.reset

    feature
  end

  def reset
    @chained = false
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

  # Runs the block with deprecated features enabled so that various methods
  # do not raise exceptions. This was added to allow specs to test
  # deprecated features. Not thread safe.
  def self.with_deprecated_strategies_enabled(value=true, &block)
    original_value = @@deprecated_strategies_enabled
    begin
      @@deprecated_strategies_enabled = value
      block.call()
    ensure
      @@deprecated_strategies_enabled = original_value
    end
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
    if !@@deprecated_strategies_enabled &&
       Trebuchet::Strategy.deprecated_strategy_names.include?(strategy_name)
      raise "The #{strategy_name} strategy is deprecated."
    end
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
  def augment(strategy_name, new_options)
    # get old options if any
    strategy_array = Trebuchet.backend.get_strategy(self.name)
    i = strategy_array.index(strategy_name)
    old_options = i ? strategy_array[i+1] : nil
    # augment them carefully
    options = if old_options == nil
      new_options
    elsif old_options.is_a?(Array) && new_options.is_a?(Array)
      old_options + new_options
    elsif old_options.is_a?(Hash) && new_options.is_a?(Hash)
      old_options.merge(new_options)
    elsif old_options.is_a?(Numeric) && new_options.is_a?(Numeric)
      old_options + new_options
    else # otherwise, change nothing
      old_options
    end
    # adjust that strategy
    self.adjust(strategy_name, options)
  end

  def dismantle
    Trebuchet.backend.remove_feature(self.name)
  end

  # add comments for a feature, as a place to hold change logs for example, to supported backends
  def add_comment(comment)
    if Trebuchet.backend.respond_to?(:add_comment)
      Trebuchet.backend.add_comment(comment)
    end
  end

  def history
    return [] unless Trebuchet.backend.respond_to?(:get_history)
    Trebuchet.backend.get_history(self.name).map do |row|
      [Time.at(row.first), Trebuchet::Strategy.find(*row.last)]
    end
  end

  def feature_id
    begin
      @feature_id ||= Trebuchet::SHA1.hexdigest(@name).to_i(16)
    rescue
      return 0
    end
  end

  def as_json(options = {})
    {:name => @name, :strategy => strategy.export}
  end

  def to_s
    str = "name: \"#{@name}\", "
    str << "#{strategy.name == :multiple ? 'strategies' : 'strategy'}: #{strategy}"
  end

  def inspect
    "#<#{self.class.name} #{self}>"
  end

  def export
    {:feature_name => name, :strategy => strategy.export}
  end

  private

  def chained?
    @chained
  end

end
