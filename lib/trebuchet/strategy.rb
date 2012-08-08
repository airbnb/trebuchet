require 'digest/sha1'

module Trebuchet::Strategy

  def self.for_feature(feature)
    strategy_args = Trebuchet.backend.get_strategy(feature.name)
    find(*strategy_args).tap {|s| s.feature = feature }
  end

  def self.find(*args)
    strategy_name, options = args

    if args.size > 2
      Multiple.new(args)
    elsif strategy_name.nil?
      # Strategy hasn't been defined yet
      Default.new
    elsif Custom.exists?(strategy_name)
      Custom.new(strategy_name, options)
    elsif klass = class_for_name(strategy_name)
      # percent, users
      klass.new(options)
    else
      Invalid.new(strategy_name, options)
    end
  end
  
  def self.name_class_map
    [
      [:percent, Percent],
      [:users, UserId],
      [:default, Default],
      [:custom, Custom],
      [:multiple, Multiple],
      [:experiment, Experiment],
      [:visitor_percent, VisitorPercent],
      [:hostname, Hostname],
      [:visitor_experiment, VisitorExperiment]
    ]
  end
  
  def self.class_for_name(name)
    classes = Hash[name_class_map]
    classes[name]
  end
  
  def self.name_for_class(klass)
    names = Hash[name_class_map.map(&:reverse)]
    names[klass]
  end
  
    
  ### Percentable module standardizes logic for percentage-based strategies
  
  module Percentable
    
    def initialize(options)
      set_range_from_options(options)
    end
    
    # must be called from initialize
    def set_range_from_options(options)
      if options == nil || options.is_a?(Numeric)
        @from = 0
        @to = options.to_i - 1
        @style = :percentage
      elsif options.is_a?(Hash) && (p = options['percentage'] || options[:percentage])
        @from = 0
        @to = p.to_i - 1
        @style = :percentage
      elsif options.is_a?(Hash)
        @from = options['from'] || options[:from]
        @to = options['to'] || options[:to]
        @style = :range
      else
        @from = 0
        @to = -1
      end
    end

    def offset
      if @style == :percentage
        feature_id % 100
      else
        0
      end
    end

    def percentage
      return 0 unless @to.is_a?(Integer) && @from.is_a?(Integer)
      return 0 if @to < 0
      ((@to - @from) + 100) % 100 + 1
    end

    # call from launch_at? and pass in user id or another integer
    def value_in_range?(value)
      return false unless @from && @to
      return false if @from.to_i < 0 || @to.to_i < 0
      return false if value == nil || !value.is_a?(Numeric)
      cutoff = percentage
      value = ((value - @from) + 200 - offset) % 100
      !!(value < cutoff)
    end
    
  end
  
  module Experimentable
    
    attr_reader :bucket, :total_buckets, :experiment_name
    
    def initialize_experiment(options)
      options.keys.each {|k| options[k.to_sym] = options.delete(k)} # cheap symbolize_keys
      @experiment_name = options[:name]
      @bucket = [ options[:bucket] ].flatten # always treat as an array
      @total_buckets = options[:total_buckets] || 5
    end
    
    def value_in_bucket?(value)
      return false if value == nil || !value.is_a?(Numeric)
      return false unless self.valid?
      # must hash feature name and value together to ensure uniform distribution
      b = Digest::SHA1.hexdigest("experiment: #{@experiment_name.downcase} user: #{value}").to_i(16) % total_buckets
      !!@bucket.include?(b + 1) # is user in this bucket?
    end
    
    def valid?
      experiment_name && total_buckets > 0 && bucket.max <= total_buckets && (1..total_buckets).include?(bucket.min)
    rescue
      false
    end

    def as_json
      {:name => experiment_name, :bucket => bucket, :total_buckets => total_buckets}
    end
    
  end

end
