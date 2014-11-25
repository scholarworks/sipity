# The foundational controller for this application
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Because yardoc's scope imperative does not appear to work, I'm pushing the
  # comments into the class definition
  class << self
    # @!attribute [rw] runner_container
    #   So you can specify where you will be finding an action's Hydramata::Runner
    #   class.
    #
    #   @see ApplicationController#run
  end
  class_attribute :runner_container

  # So you can more easily decouple the controller's command behavior and
  # response behavior.
  #
  # @example
  #   def index
  #     run(specific_params) do |on|
  #       on.success { |collection|
  #         @collection = collection
  #         respond_with(@collection)
  #       }
  #     end
  #   end
  #
  # @see ApplicationController.runner_container for customization
  def run(*args, &block)
    runner.run(self, *args, &block)
  end

  attr_writer :runner
  def runner
    return @runner if @runner # For Dependency Injection
    runner_name = action_name.classify
    if runner_container.const_defined?(runner_name)
      runner_container.const_get(runner_name)
    else
      fail RunnerNotFoundError, container: runner_container, name: runner_name
    end
  end

  # Raised when a Runner is not found
  class RunnerNotFoundError < RuntimeError # :nodoc:
    def initialize(container:, name:)
      super("Unable to find #{name} in #{container}")
    end
  end

  # So you can easily invoke the public repository of Hydramata.
  # It is these repository that indicate what the application can and is doing.
  #
  # @see Cur8Nd::Repository for the default methods
  def repository
    @repository = Sip::Repository.new
  end
  helper_method :repository
end
