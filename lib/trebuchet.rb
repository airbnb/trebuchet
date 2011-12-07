class Trebuchet

  class << self
    attr_accessor :admin_view, :admin_edit
    
    def backend
      self.backend = :memory unless @backend
      @backend
    end
    
    def set_backend(backend_type, *args)
      require "trebuchet/backend/#{backend_type}"
      @backend = Backend.lookup(backend_type).new(*args)
    end
    
    # this only works with additional args, e.g.: Trebuchet.backend = :memory
    alias_method :backend=, :set_backend 
    
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
require 'trebuchet/version'
require 'trebuchet/error'
require 'trebuchet/backend'
require 'trebuchet/backend/disabled'
# load other backends on demand so their dependencies can load first
require 'trebuchet/feature'
require 'trebuchet/strategy'
require 'trebuchet/strategy/base'
require 'trebuchet/strategy/default'
require 'trebuchet/strategy/percentage'
require 'trebuchet/strategy/user_id'
require 'trebuchet/strategy/experiment'
require 'trebuchet/strategy/custom'
require 'trebuchet/strategy/invalid'
require 'trebuchet/strategy/multiple'
require 'trebuchet/action_controller'
