require 'cogitate/interfaces'
module Sipity
  module Services
    # Responsible for assisting in the negotiation of Authentication
    class AuthenticationLayer
      # @api public
      #
      # The public interface for authentication when none is required.
      def self.none!(*)
        return true
      end

      # @api public
      #
      # The public interface for authenticating a user
      def self.authenticate_user!(context, **keywords)
        new(context: context, **keywords).authenticate_user!
      end

      # @api public
      #
      # The default public interface for authenticating a user
      def self.default!(context, **keywords)
        new(context: context, **keywords).authenticate_user!
      end

      # @api public
      def self.authenticate_user_with_disregard_for_approval_of_terms_of_service!(context, **keywords)
        new(context: context, **keywords).authenticate_user_with_disregard_for_approval_of_terms_of_service!
      end

      def initialize(context:, current_user_extractor: default_current_user_extractor)
        self.context = context
        self.current_user_extractor = current_user_extractor
      end

      def capture_cogitate_token(token:)
        context.session[:cogitate_data] = token
      end

      # @api private
      # @todo https://github.com/ndlib/sipity/issues/888
      # rubocop:disable IdenticalConditionalBranches
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
      # rubocop:enable IdenticalConditionalBranches

      # @api private
      # @todo https://github.com/ndlib/sipity/issues/888
      def authenticate_user_with_disregard_for_approval_of_terms_of_service!
        set_current_user
        return current_user if current_user.user_signed_in?
        # Warden leverages halt imperatives to ensure that redirection is more appropriately handled.
        context.redirect_to('/authenticate')
        return false
      end

      private

      def set_current_user
        @current_user = current_user_extractor.call(session: context.session)
        context.send(:current_user=, @current_user)
        @current_user
      end

      attr_reader :current_user

      attr_accessor :context, :current_user_extractor

      def default_current_user_extractor
        require 'sipity/services/current_agent_from_session_extractor' unless defined?(CurrentAgentFromSessionExtractor)
        CurrentAgentFromSessionExtractor
      end
    end
  end
end
