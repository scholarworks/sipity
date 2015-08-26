require 'sipity/interfaces'

module Sipity
  module Models
    # The "current user" of application.
    class Agent
      include Contracts
      Contract(
        KeywordArgs[token: String, token_decoder: Optional[RespondTo[:call]]] => Sipity::Interfaces::AgentInterface
      )
      def self.new_from_cogitate_token(token:, token_decoder: default_token_decoder)
        cogitate_agent = token_decoder.call(token: token)
        new(cogitate_agent)
      end

      def self.default_token_decoder
        require 'cogitate/client/token_to_object_coercer' unless defined?(Cogitate::Client::TokenToObjectCoercer)
        Cogitate::Client::TokenToObjectCoercer
      end
      private_class_method :default_token_decoder

      # Yup, I'm privatizing the .new method. If you want an Agent use one of the custom new methods on this class.
      private_class_method :new

      def initialize(cogitate_agent)
        self.cogitate_agent = cogitate_agent
      end

      def email
        cogitate_agent.with_emails.to_a.first
      end

      delegate :ids, :name, to: :cogitate_agent

      private

      attr_accessor :cogitate_agent
    end
  end
end
