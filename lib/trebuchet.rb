class Trebuchet

  VERSION = "0.0.1"

  def self.backend
    self.backend = :memory unless defined? @@backend
    @@backend
  end

  def self.backend=(args)
    args = Array(args)
    @@backend = Backend.lookup(args.shift).new(*args)
  end

  def self.aim(feature_name, *args)
    Feature.find(feature_name).aim(*args)
  end

  def self.define_strategy(name, &block)
    Strategy::Custom.define(name, block)
  end

  def self.feature(name)
    Feature.find(name)
  end

  def self.use_with_rails!
    ::ActionController::Base.send(:include, Trebuchet::ActionController)
  end

  def initialize(current_user, request = nil)
    @current_user = current_user
    @request = request
  end

  def launch(feature, &block)
    yield if launch?(feature)
  end

  def launch?(feature)
    Feature.find(feature).launch_at?(@current_user)
  end

end


require 'set'
require 'trebuchet/backend'
require 'trebuchet/backend/memory'
require 'trebuchet/backend/memcached'
require 'trebuchet/feature'
require 'trebuchet/strategy'
require 'trebuchet/strategy/default'
require 'trebuchet/strategy/percentage'
require 'trebuchet/strategy/user_id'
require 'trebuchet/strategy/custom'
require 'trebuchet/strategy/multiple'
require 'trebuchet/action_controller'
