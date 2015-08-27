require 'cogitate/interfaces'
module Sipity
  module Services
    # Responsible for assisting in the negotiation of Authentication
    class AuthenticationLayer
      def initialize(context:)
        self.context = context
      end

      delegate :session, to: :context

      def capture_cogitate_token(token:)
        session[:cogitate_token] = token
      end

      def authenticate_user!
        set_current_user
        return current_user if current_user.user_signed_in?
        # Warden leverages halt imperatives to ensure that redirection is more appropriately handled.
        context.redirect_to('/authenticate')
        return false
      end

      private

      def set_current_user
        @current_user = current_user_from_session
        context.current_user = @current_user
        @current_user
      end

      attr_reader :current_user

      include Contracts
      Contract(None => RespondTo[:user_signed_in?])
      def current_user_from_session
        if session.key?(:cogitate_token)
          Sipity::Models::Agent.new_from_cogitate_token(token: session[:cogitate_token])
        elsif session.key?(:validated_resource_id)
          Sipity::Models::Agent.new_from_user_id(user_id: session[:validated_resource_id])
        else
          Sipity::Models::Agent.new_null_agent
        end
      end

      attr_accessor :context
    end
  end
end
