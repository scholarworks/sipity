require 'sipity/interfaces'
require 'cogitate/client'

module Sipity
  module Models
    # The "current user" of application.
    module Agent
      include Contracts
      Contract(KeywordArgs[token: String, token_decoder: Optional[RespondTo[:call]]] => Sipity::Interfaces::AgentInterface)
      def self.new_from_cogitate_token(token:, token_decoder: default_token_decoder, **keywords)
        cogitate_agent = token_decoder.call(token: token)
        Sipity::Models::Agent::FromCogitate.new(cogitate_agent: cogitate_agent, **keywords)
      end

      Contract(KeywordArgs[user_id: Or[String, Integer]] => Sipity::Interfaces::AgentInterface)
      def self.new_from_user_id(user_id:)
        user = User.find(user_id)
        Sipity::Models::Agent::FromDevise.new(user: user)
      end

      Contract(None => Sipity::Interfaces::AgentInterface)
      def self.new_null_agent
        Sipity::Models::Agent::NullAgent.new
      end

      def self.default_token_decoder
        require 'cogitate/client/token_to_object_coercer' unless defined?(Cogitate::Client::TokenToObjectCoercer)
        Cogitate::Client::TokenToObjectCoercer
      end
      private_class_method :default_token_decoder
    end
  end
end
