require 'digest/sha1'
require 'forwardable'
class Trebuchet
  # initialize a single one to save object allocations
  # Todo perhaps choose a better hash instead of sha1
  SHA1 = Digest::SHA1.new

  class << self
    extend Forwardable

    def_delegators :state, :current=, :current_block=, :current_block,
      :logs, :admin_view, :admin_view=, :admin_edit, :admin_edit=,
      :time_zone, :time_zone=, :author=, :author, :visitor_id

    attr_accessor :exception_handler
    attr_accessor :threadsafe_state

    def backend
      self.backend = :memory unless @backend
      @backend
    end

    def set_backend(backend_type, *args)
      if backend_type.is_a?(Symbol)
        require "trebuchet/backend/#{backend_type}"
        @backend = Backend.lookup(backend_type).new(*args)
      elsif backend_type.class.name =~ /Trebuchet::Backend/
        @backend = backend_type
      end
    end

    # this only works with additional args, e.g.: Trebuchet.backend = :memory
    alias_method :backend=, :set_backend

    alias_method :threadsafe_state?, :threadsafe_state

    # Logging done at class level
    # TODO: split by user identifier so instance can return scoped to one user
    # (in case multiple users have user.trebuchet called)
    def initialize_logs
      state.logs = {}
    end

    def log(feature_name, result)
      initialize_logs if state.logs.nil?
      logs[feature_name] = result
    end

    def logs
      state.logs
    end

    def current=(other)
      state.current = other
    end

    def current
      state.current ||= current_block.call if current_block.respond_to?(:call)
      state.current || new(nil) # return an blank Trebuchet instance if @current is not set
    end

    def reset_current!
      self.current = nil
    end

    def thread_local_key
      :trebuchet_state
    end

    # state is a representation of the current context of Trebuchet such as current and
    # current_proc, which are expected to be different between threads or fibers.
    # exception_handler and backend are not included in this state object as they are
    # not expected to change from fiber to fiber or request to request, therefore they
    # must be thread/fibersafe on their own accord.
    def state
      if threadsafe_state?
        Thread.current[thread_local_key] ||= State.new
      else
        @state ||= State.new
      end
    end

    def state=(new_state)
      if threadsafe_state?
        Thread.current[thread_local_key] = new_state
      else
        @state = new_state
      end
    end

    def threadsafe_state?
      threadsafe_state
    end
  end

  def self.aim(feature_name, *args)
    Feature.find(feature_name).aim(*args)
  end

  def self.dismantle(feature_name)
    Feature.find(feature_name).dismantle
  end

  def self.dismantle_stubs
    Feature.dismantle_stubs
  end

  def self.define_strategy(name, &block)
    Strategy::Custom.define(name, block)
  end

  def self.define_request_aware_strategy(name, &block)
    Strategy::CustomRequestAware.define(name, block)
  end

  def self.visitor_id=(id_or_proc)
    if id_or_proc.is_a?(Proc)
      state.visitor_id = id_or_proc
    elsif id_or_proc.is_a?(Integer)
      state.visitor_id = proc { |request| id_or_proc }
    else
      state.visitor_id = nil
    end
  end

  def self.use_with_rails!
    if defined?(ActionController::Base)
      ActionController::Base.send(:include, Trebuchet::ActionController)
    end
  end

  def self.feature(name)
    Feature.find(name)
  end

  def initialize(current_user, request = nil)
    @current_user = current_user
    @request = request
    @result_cache = {}
  end

  def launch(feature, &block)
    if launch?(feature)
      yield if block_given?
    end
  end

  def launch?(feature)
    result = @result_cache[feature]

    if result.nil?
      result = @result_cache[feature] =
        !!Feature.find(feature).launch_at?(@current_user, @request)
      Trebuchet.log(feature, result)
    end

    result
  rescue => e
    handle_exception(e, feature)
    return false
  end

  def handle_exception(exception, feature = nil)
    if self.class.exception_handler.is_a?(Proc)
      argc = self.class.exception_handler.arity
      argc = 3 if argc < 0
      self.class.exception_handler.call *[exception, feature, self][0,argc]
    end
  end

  def self.export
    {}.tap do |features|
      Trebuchet.backend.get_feature_names.map do |fn|
        features[fn] = self.feature(fn).strategy.export
      end
    end
  end

  def self.history(include_archived = false)
    return [] unless Trebuchet.backend.respond_to?(:get_all_history)
    Trebuchet.backend.get_all_history(include_archived).map do |row|
      [Time.at(row.first), Feature.find(row.last)]
    end
  end

end

require 'set'
require 'trebuchet/version'
require 'trebuchet/error'
require 'trebuchet/backend'
require 'trebuchet/backend/disabled'
# load other backends on demand so their dependencies can load first
require 'trebuchet/state'
require 'trebuchet/feature'
require 'trebuchet/strategy'
require 'trebuchet/strategy/base'
require 'trebuchet/strategy/custom'
require 'trebuchet/strategy/custom_request_aware'
require 'trebuchet/strategy/default'
require 'trebuchet/strategy/everyone'
require 'trebuchet/strategy/experiment'
require 'trebuchet/strategy/hostname'
require 'trebuchet/strategy/invalid'
require 'trebuchet/strategy/logic_and'
require 'trebuchet/strategy/logic_not'
require 'trebuchet/strategy/logic_or'
require 'trebuchet/strategy/multiple'
require 'trebuchet/strategy/nobody'
require 'trebuchet/strategy/percent'
require 'trebuchet/strategy/percent_deprecated'
require 'trebuchet/strategy/per_denomination'
require 'trebuchet/strategy/user_id'
require 'trebuchet/strategy/visitor_experiment'
require 'trebuchet/strategy/visitor_percent'
require 'trebuchet/strategy/visitor_percent_deprecated'

require 'trebuchet/strategy/stub'
require 'trebuchet/action_controller'
