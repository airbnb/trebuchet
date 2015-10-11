require 'digest/sha1'

module Trebuchet::Strategy

  def self.for_feature(feature)
    stub_state = Trebuchet::Feature.stubbed_features[feature.name]
    if stub_state
      Stub.new(stub_state)
    else
      strategy_args = Trebuchet.backend.get_strategy(feature.name)
      find(*strategy_args).tap {|s| s.feature = feature }
    end
  end

  def self.find(*args)
    strategy_name, options = args

    if args.size > 2
      Multiple.new(args)
    elsif strategy_name.nil? || strategy_name == :default
      # Strategy hasn't been defined yet
      Default.instance
    elsif Custom.exists?(strategy_name)
      Custom.new(strategy_name, options)
    elsif klass = class_for_name(strategy_name)
      # percent, users
      klass.new(options)
    else
      Invalid.new(strategy_name, options)
    end
  end

  # The stub strategy purposely left out of this list as it should be
  # accessible via the testing interface only and not externally.
  def self.name_class_map
    [
      [:visitor_percent_deprecated, VisitorPercentDeprecated],
      [:percent_deprecated, PercentDeprecated],
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

  def self.deprecated_strategy_names
    [
      :percent_deprecated,
      :visitor_percent_deprecated
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

    attr_reader :percentage

    def initialize(options)
      set_range_from_options(options)
    end

    # must be called from initialize
    def set_range_from_options(options)
      if options == nil || options.is_a?(Numeric)
        @percentage = options.to_i
      else
        @percentage = 0
      end
    end

    def value_in_range?(value)
      bucket =
          Digest::SHA1.hexdigest("#{@feature.name}|#{value}").to_i(16) % 100
      bucket < @percentage
    end

    def to_s
      kind = self.name == :visitor_percent ? "visitors" : "users"
      percentage_str = "#{@percentage}% of #{kind}"
      "#{percentage_str}"
    end

    def export
      super @percentage
    end
  end


  # This module is deprecated because the implementation is such that it's
  # not possible to trust per-feature analysis if multiple features are
  # using the PercentableDeprecated based strategies because the same
  # visitors will tend to get the same features (even with the offset).
  module PercentableDeprecated

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

    def offset_from
      (@from + offset) % 100
    end

    def offset_to
      (@to + offset) % 100
    end

    def to_s
      kind = self.name == :visitor_percent ? "visitors" : "users"
      percentage_str = "#{percentage}% of #{kind}"
      range_str = if @to < 0
        "nobody"
      else
        str = ''
        str << "user id ending with " if kind != "visitors"
        str << "#{offset_from.to_s.rjust(2, '0')}"
        str << " to #{offset_to.to_s.rjust(2, '0')}" if @to != @from
        str
      end
      @style == :range ? "#{range_str} (#{percentage_str})" : "#{percentage_str} (#{range_str})"
    end

    def export
      if @style == :percentage
        super :percentage => @to
      else
        super :from => @from, :to => @to
      end
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

    def type
      "#{name == :experiment ? "user" : "visitor"} experiment"
    end

    def as_json(options = {})
      {
        :name => experiment_name,
        :bucket => bucket,
        :total_buckets => total_buckets,
        :type => self.type
      }
    end

    def to_s
      str = "buckets (#{bucket.join(', ')}) of total: #{total_buckets}"
      str << " for #{self.type} experiment: #{experiment_name}"
    end

    def export
      super :name => experiment_name, :bucket => bucket, :total_buckets => total_buckets
    end

    def inspect
      "#<#{self.class.name} #{self}>"
    end

  end

end
