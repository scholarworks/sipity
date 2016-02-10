require 'hesburgh/lib/runner'
require 'sipity/exceptions'
require 'sipity/services/authorization_layer'

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
      class_attribute :authorization_layer, instance_accessor: false
      class_attribute :action_name, instance_accessor: false

      # Because yardoc's scope imperative does not appear to work, I'm pushing the
      # comments into the class definition
      class << self
        # @!attribute [rw] authorization_layer
        #   @return [#enforce!(question/entity pairs)]
        #   @see Sipity::BaseRunner#authorization_layer=
        #
        # @!attribute [rw] authentication_layer
        #   @return [#call(context)]
        #   @see Sipity::BaseRunner#authentication_layer=
        #
        # @!attribute [rw] action_name
        #   @return [String]
        #   @see Sipity::BaseRunner#action_name
      end
      self.authorization_layer = :none
      self.authentication_layer = :none
      self.action_name = nil

      # @param context [#current_user, #repository] The containing context in
      #   which the runner is acting. This is likely an ApplicationController.
      # @param options [Hash] configuration options
      # @option options [#call(context), false, :default, :none]
      #   :authentication_layer defines how authentication will or will not be enforced/verified.
      # @option options [#enforce!] :authorization_layer What are the authorization_layer that should
      #   be in effect for this instance?
      #
      # @note By convention, the Rails application will instantiate this object
      #   without passing any options; Thus the class configuration options will be
      #   used. However, it is possible that another application (i.e. a command-
      #   line application) would opt to instead instantiate the object directly.
      def initialize(context, options = {}, &block)
        super(context, &block)
        self.authentication_layer = options.fetch(:authentication_layer) { self.class.authentication_layer }
        self.authorization_layer = options.fetch(:authorization_layer) { self.class.authorization_layer }
      end

      delegate :repository, :current_user, to: :context
      attr_reader :authentication_layer, :authorization_layer
      private :authentication_layer, :authorization_layer

      # The returned value should be the response from the call of a
      # NamedCallback.
      #
      # @return results of the #callback method
      #
      # @see NamedCallback
      def run(*)
        raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
      end

      def action_name
        self.class.action_name || self.class.to_s.demodulize.underscore
      end

      private

      # @todo Tease out a builder object
      def authentication_layer=(uncoerced_layer)
        return @authentication_layer = uncoerced_layer if uncoerced_layer.respond_to?(:call)
        @authentication_layer = begin
          case uncoerced_layer
          when :none, false, nil then authentication_layer_that_authenticates_anything
          when :default, true then authentication_layer_that_uses_context_authentication
          else
            raise Exceptions::FailedToBuildAuthenticationLayerError
          end
        end
      end

      def authentication_layer_that_authenticates_anything
        -> (*) { true }
      end

      def authentication_layer_that_uses_context_authentication
        # Devise provides helpful authentication options; I'm using those.
        ->(context) { context.authenticate_user! }
      end

      def enforce_authentication!
        return true if authentication_layer.call(context)
        # I am choosing to raise this exception because the default authentication
        # service has likely thrown an exception if things have failed. This is
        # my last line of defense. If you encounter this exception, make sure
        # to review the authentication_service method for its output.
        raise Exceptions::AuthenticationFailureError, self.class
      end

      # @todo Tease out a builder
      def authorization_layer=(uncoerced_layer)
        return @authorization_layer = uncoerced_layer.call(self) if uncoerced_layer.respond_to?(:call)
        @authorization_layer = begin
          case uncoerced_layer
          when :none, false, nil then authorization_layer_that_authorizes_everything
          when :default, true then authorization_layer_with_enforcement
          else
            raise Exceptions::FailedToBuildAuthorizationLayerError
          end
        end
      end

      def authorization_layer_with_enforcement
        Services::AuthorizationLayer.new(self)
      end

      def authorization_layer_that_authorizes_everything
        Services::AuthorizationLayer::AuthorizeEverything.new(self)
      end
    end
  end
end
