module Trebuchet::Strategy

  def self.for_feature(feature)
    strategy_args = Trebuchet.backend.get_strategy(feature.name)
    find(*strategy_args)
  end

  def self.find(*args)
    strategy_name, options = args

    if args.size > 2
      Multiple.new(args)
    elsif strategy_name.nil?
      # Strategy hasn't been defined yet
      Default.new
    elsif strategy_name == :percent
      Percentage.new(options)
    elsif strategy_name == :users
      UserId.new(options)
    elsif Custom.exists?(strategy_name)
      Custom.new(strategy_name, options)
    else
      raise ArgumentError.new("Unsupported strategy: #{strategy_name}")
    end
  end

end
