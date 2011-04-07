class Trebuchet::Strategy::Multiple

  attr_reader :strategies

  def initialize(args)
    @strategies = []
    args.each_slice(2) do |pair|
      @strategies << Trebuchet::Strategy.find(*pair)
    end
  end

  def launch_at?(user)
    strategies.find { |s| s.launch_at?(user) }
  end

end
