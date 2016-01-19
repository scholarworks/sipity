module Sipity
  # Responsible for being a valid context for running a Sipity::Runner
  #
  #
  # @example
  #   context = Sipity::CommandLineContext.new(requested_by: a_user)
  #   runner = Sipity::Runners::WorkSubmissionsRunner.new(context)
  #   runner.run(work_id: 123)
  #
  # @param requested_by [#to_processing_actor]
  # @param repository_strategy [#to_s] :query and :command are the two likely repositories
  #
  # @see Sipity::Runners
  class CommandLineContext
    def initialize(requested_by:, repository_strategy: default_repository_strategy)
      self.requested_by = requested_by
      self.repository_strategy = repository_strategy
    end

    attr_reader :repository, :requested_by
    alias_method :current_user, :requested_by

    private

    IS_A_AUTHENTICATE_METHOD_REGEXP = /\Aauthenticate_(.*)!\Z/

    def method_missing(method_name, *args, &block)
      return current_user.present? if method_name =~ IS_A_AUTHENTICATE_METHOD_REGEXP
      super
    end

    def respond_to_missing?(method_name, *args)
      method_name =~ IS_A_AUTHENTICATE_METHOD_REGEXP || super
    end

    # @todo When Cogitate is deployed switch from ConvertToProcessingActor
    def requested_by=(input)
      @requested_by = Conversions::ConvertToProcessingActor.call(input)
    end

    def repository_strategy=(input)
      filename = "#{input.to_s.underscore}_repository"
      require "sipity/#{filename}" unless defined?(Sipity.const_get(filename.classify))
      @repository = Sipity.const_get(filename.classify).new
    end

    def default_repository_strategy
      :command
    end
  end
end
