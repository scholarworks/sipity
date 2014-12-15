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
      class_attribute :authentication_layer, instance_accessor: false
      class_attribute :enforces_authorization, instance_accessor: false

      # Because yardoc's scope imperative does not appear to work, I'm pushing the
      # comments into the class definition
      class << self
        # @!attribute [rw] enforces_authorization
        #   If true, then the runner will apply a more rigorous authorization_layer.
        #
        #   @return [Boolean]
        #
        # @!attribute [rw] authentication_layer
        #   @return [#call(context)]
        #   @see Sipity::BaseRunner#authentication_layer=
      end
      self.enforces_authorization = false
      self.authentication_layer = :none

      # @param context [#current_user, #repository] The containing context in
      #   which the runner is acting. This is likely an ApplicationController.
      # @param options [Hash] configuration options
      # @option options [#call(context), false, :default, :none]
      #   :authentication_layer defines how authentication will or will not be enforced/verified.
      # @option options [#call] :authentication_layer
      # @option options [Boolean] :enforces_authorization will this instance
      #   enforce authorizations? Or will the underlying authorization_layer authorize everything?
      # @option options [#enforce!] :authorization_layer What are the authorization_layer that should
      #   be in effect for this instance?
      #
      # @note By convention, the Rails application will instantiate this object
      #   without passing any options; Thus the class configuration options will be
      #   used. However, it is possible that another application (i.e. a command-
      #   line application) would opt to instead instantiate the object directly.
      #
      # REVIEW: Should the two parameters for authentication be consolidated
      #   into one?
      # REVIEW: Should the two parameters for authorization related services be
      #   consolidated into one?
      def initialize(context, options = {}, &block)
        super(context, &block)
        self.authentication_layer = options.fetch(:authentication_layer) { self.class.authentication_layer }
        enforce_authentication!
        @enforces_authorization = options.fetch(:enforces_authorization) { self.class.enforces_authorization }
        @authorization_layer = options.fetch(:authorization_layer) { default_authorization_layer }
      end

      delegate :repository, :current_user, to: :context
      attr_reader :authentication_layer, :enforces_authorization, :authorization_layer
      private :authentication_layer, :enforces_authorization, :authorization_layer

      # The returned value should be the response from the call of a
      # NamedCallback.
      #
      # @return results of the #callback method
      #
      # @see NamedCallback
      def run(*)
        fail NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
      end

      private

      def default_authorization_layer
        if enforces_authorization.present?
          Services::AuthorizationLayer.new(self)
        else
          Services::AuthorizationLayer::AuthorizeEverything.new(self)
        end
      end

      def authentication_layer=(uncoerced_layer)
        return @authentication_layer = uncoerced_layer if uncoerced_layer.respond_to?(:call)
        case uncoerced_layer
        when :none, false, nil then
          @authentication_layer = authenticates_everything
        when :default, true then
          @authentication_layer = use_context_authentication
        else
          fail Exceptions::FailedToBuildAuthenticationLayerError
        end
      end

      def authenticates_everything
        -> (*) { true }
      end

      def use_context_authentication
        ->(context) { context.authenticate_user! }
      end

      def enforce_authentication!
        return true if authentication_layer.call(context)
        # I am choosing to raise this exception because the default authentication
        # service has likely thrown an exception if things have failed. This is
        # my last line of defense. If you encounter this exception, make sure
        # to review the authentication_service method for its output.
        fail Exceptions::AuthenticationFailureError, self.class
      end
    end
  end
end
