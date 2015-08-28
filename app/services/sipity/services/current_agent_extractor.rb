require 'sipity/models/agent'
module Sipity
  module Services
    # Responsible for extracting an agent from the given session
    module CurrentAgentFromSessionExtractor
      def self.call(session:)
        if session.key?(:cogitate_token)
          Sipity::Models::Agent.new_from_cogitate_token(token: session[:cogitate_token])
        elsif session.key?(:validated_resource_id)
          Sipity::Models::Agent.new_from_user_id(user_id: session[:validated_resource_id])
        elsif session.key?('warden.user.user.key')
          # We have something that looks like `[[1], nil]` in the session
          user_id = session['warden.user.user.key'].first.first
          Sipity::Models::Agent.new_from_user_id(user_id: user_id)
        else
          Sipity::Models::Agent.new_null_agent
        end
      end
    end
  end
end
