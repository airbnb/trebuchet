class Trebuchet

  @@visitor_id = nil

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
    
    # Logging done at class level
    # TODO: split by user identifier so instance can return scoped to one user
    # (in case multiple users have user.trebuchet called)
    def initialize_logs
      @logs = {}
    end
    
    def log(feature_name, result)
      initialize_logs if @logs == nil
      @logs[feature_name] = result
    end

    attr_reader :logs
    attr_accessor :current

    def current
      @current = @current.call if @current.is_a?(Proc)
      @current
    end
    
  end

  def self.aim(feature_name, *args)
    Feature.find(feature_name).aim(*args)
  end

  def self.define_strategy(name, &block)
    Strategy::Custom.define(name, block)
  end

  def self.visitor_id=(id_or_proc)
    if id_or_proc.is_a?(Proc)
      @@visitor_id = id_or_proc
    elsif id_or_proc.is_a?(Integer)
      @@visitor_id = proc { |request| id_or_proc }
    else
      @@visitor_id = nil
    end
  end

  def self.visitor_id
    @@visitor_id
  end

  def self.use_with_rails!
    ::ActionController::Base.send(:include, Trebuchet::ActionController)
  end

  def self.feature(name)
    Feature.find(name)
  end

  def initialize(current_user, request = nil)
    @current_user = current_user
    @request = request
    @logs = {}
  end

  def launch(feature, &block)
    if launch?(feature)
      yield if block_given?
    end
  end

  def launch?(feature)
    result = !!Feature.find(feature).launch_at?(@current_user, @request)
    Trebuchet.log(feature, result)
    return result
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
require 'trebuchet/strategy/percent'
require 'trebuchet/strategy/user_id'
require 'trebuchet/strategy/experiment'
require 'trebuchet/strategy/visitor_experiment'
require 'trebuchet/strategy/custom'
require 'trebuchet/strategy/invalid'
require 'trebuchet/strategy/multiple'
require 'trebuchet/strategy/visitor_percent'
require 'trebuchet/strategy/hostname'
require 'trebuchet/action_controller'
