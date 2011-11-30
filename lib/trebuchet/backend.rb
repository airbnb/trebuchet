module Trebuchet::Backend

  def self.lookup(name)
    # From ActiveSupport::Inflector.camelize
    const_name = name.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }

    if const_defined?(const_name)
      const_get(const_name)
    else
      raise ArgumentError.new("Unknown backend type #{name}")
    end
  end

end
