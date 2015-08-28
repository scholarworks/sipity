require 'cogitate/interfaces'
module Sipity
  module Services
    # Responsible for assisting in the negotiation of Authentication
    class AuthenticationLayer
      # @api public
      #
      # The public interface for authentication when none is required.
      def self.none!(**)
        return true
      end

      # @api public
      #
      # The public interface for authenticating a user
      def self.authenticate_user!(context:, **keywords)
        new(context: context, **keywords).authenticate_user!
      end

      # @api public
      #
      # The default public interface for authenticating a user
      def self.default!(context:, **keywords)
        new(context: context, **keywords).authenticate_user!
      end

      # @api public
      def self.authenticate_user_with_disregard_for_approval_of_terms_of_service!(context:, **keywords)
        new(context: context, **keywords).authenticate_user_with_disregard_for_approval_of_terms_of_service!
      end

      def initialize(context:, current_user_extractor: default_current_user_extractor)
        self.context = context
        self.current_user_extractor = current_user_extractor
      end

      def capture_cogitate_token(token:)
        context.session[:cogitate_token] = token
      end

      # @api private
      def authenticate_user!
        set_current_user
        if current_user.user_signed_in?
          return current_user if current_user.agreed_to_application_terms_of_service?
          context.redirect_to('/account')
          return false
        else
          context.redirect_to('/authenticate')
          return false
        end
      end

      # @api private
      def authenticate_user_with_disregard_for_approval_of_terms_of_service!
        set_current_user
        return current_user if current_user.user_signed_in?
        # Warden leverages halt imperatives to ensure that redirection is more appropriately handled.
        context.redirect_to('/authenticate')
        return false
      end

      private

      def set_current_user
        @current_user = current_user_extractor.call(context: context)
        context.send(:current_user=, @current_user)
        @current_user
      end

      attr_reader :current_user

      include Contracts
      Contract(KeywordArgs[context: RespondTo[:session]] => RespondTo[:user_signed_in?, :agreed_to_application_terms_of_service?])
      # @todo Extract this method to the Sipity::Models::Agent.extract_from_session(session: context.session)
      def current_user_from_session(context:)
        if context.session.key?(:cogitate_token)
          Sipity::Models::Agent.new_from_cogitate_token(token: context.session[:cogitate_token])
        elsif context.session.key?(:validated_resource_id)
          Sipity::Models::Agent.new_from_user_id(user_id: context.session[:validated_resource_id])
        elsif context.session.key?('warden.user.user.key')
          # We have something that looks like `[[1], nil]` in the session
          user_id = context.session['warden.user.user.key'].first.first
          Sipity::Models::Agent.new_from_user_id(user_id: user_id)
        else
          Sipity::Models::Agent.new_null_agent
        end
      end

      attr_accessor :context, :current_user_extractor

      def default_current_user_extractor
        method(:current_user_from_session)
      end
    end
  end
end
