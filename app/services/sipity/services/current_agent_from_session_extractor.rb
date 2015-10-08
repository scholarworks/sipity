require 'sipity/models/authentication_agent'
module Sipity
  module Services
    # Responsible for extracting an agent from the given session
    module CurrentAgentFromSessionExtractor
      extend Contracts

      Contract(
        Contracts::KeywordArgs[session: Contracts::RespondTo[:key?, :[]]] =>
        Contracts::RespondTo[:signed_in?, :agreed_to_application_terms_of_service?]
      )
      def self.call(session:, builder: Sipity::Models::AuthenticationAgent)
        return builder.new_from_cogitate_token(token: session[:cogitate_token]) if session.key?(:cogitate_token)
        return builder.new_from_cogitate_data(data: session[:cogitate_data]) if session.key?(:cogitate_data)
        # Looks like Devise and Warden are still cooperating with us.
        return builder.new_from_user_id(user_id: session[:validated_resource_id]) if session.key?(:validated_resource_id)

        if session.key?('warden.user.user.key')
          # We have something that looks like `[[1], nil]` in the session
          user_id = session['warden.user.user.key'].first.first
          builder.new_from_user_id(user_id: user_id)
        else
          builder.new_null_agent
        end
      end
    end
  end
end
