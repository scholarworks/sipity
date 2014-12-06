require 'hesburgh/lib/runner'

module Sipity
  module Runners
    # A simple insulating layer between this application and Hesburgh::Lib
    #
    # Defines how the application layer interacts with the repository layer.
    #
    # The primary purpose of the Runner is to offload much of the processing
    # decisions from the controller. This instead lets the controller worry about
    # generating the correct response (e.g. render a template or redirect to
    # another URI) based on the results of the Runner.
    #
    # In offloading the processing from the controller, the runner can, with
    # minimal adjustments, operate in a different context. In other words, a
    # Runner could be used to build a suite of command-line commands.
    #
    # @note You will need to define the #run method on any subclasses.
    class BaseRunner < Hesburgh::Lib::Runner
      class_attribute :requires_authentication, instance_accessor: false
      class_attribute :authentication_service, instance_accessor: false
      class_attribute :policy_question

      # Does this runner require authentication? This is not authorization. We
      # care only if the user is signed in, not who or what they are.
      self.requires_authentication = false

      # If you are going to enforce a policy but forget to define it, I want
      # to attempt to perform a policy with a symbol that is rather explicit.
      self.policy_question = :policy_always_fails_so_change_it!

      # The default authentication service is from Devise; Perhaps this is
      # something to configure at the application level.
      self.authentication_service = ->(context) { context.authenticate_user! }

      # @param context [#current_user, #repository] The containing context in
      #   which the runner is acting. This is likely an ApplicationController.
      # @param options [Hash] configuration options
      # @option options [Boolean] :requires_authentication will this instance
      #   check if we need an authenticated user?
      # @option options [#call] :authentication_service if authentication is
      #   required, this lambda will be called. It should return true if we have
      #   a user, or false otherwise.
      #
      # @note By convention, the Rails application will instantiate this object
      #   without passing any options; Thus the class configuration options will be
      #   used. However, it is possible that another application (i.e. a command-
      #   line application) would opt to instead instantiate the object directly.
      def initialize(context, options = {}, &block)
        super(context, &block)
        @requires_authentication = options.fetch(:requires_authentication) { self.class.requires_authentication }
        @authentication_service = options.fetch(:authentication_service) { self.class.authentication_service }
        enforce_authentication!
      end

      delegate :repository, :current_user, to: :context
      attr_reader :requires_authentication, :authentication_service
      private :requires_authentication, :authentication_service

      private

      def enforce_authentication!
        return true unless requires_authentication?
        return true if authentication_service.call(context)
        # I am choosing to raise this exception because the default authentication
        # service has likely thrown an exception if things have failed. This is
        # my last line of defense. If you encounter this exception, make sure
        # to review the authentication_service method for its output.
        fail Exceptions::AuthenticationFailureError, self.class
      end

      def requires_authentication?
        requires_authentication.present?
      end
    end
  end
end
