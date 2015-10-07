require 'sipity/interfaces'
require 'cogitate/client'

module Sipity
  module Models
    # The "current user" of application.
    #
    # @todo Compose the Models::IdentifiableAgent into an AuthenticationAgent
    class AuthenticationAgent
      include Contracts
      # @todo Replace FromAgent with instantiation of AuthenticationAgent; However, apply the strategy
      Contract(KeywordArgs[token: String, token_decoder: Optional[RespondTo[:call]]] => Sipity::Interfaces::AuthenticationAgentInterface)
      def self.new_from_cogitate_token(token:, token_decoder: default_token_decoder, **keywords)
        cogitate_agent = token_decoder.call(token: token)
        Sipity::Models::AuthenticationAgent::FromCogitate.new(cogitate_agent: cogitate_agent, **keywords)
      end

      Contract(KeywordArgs[data: Hash, data_coercer: Optional[RespondTo[:call]]] => Sipity::Interfaces::AuthenticationAgentInterface)
      def self.new_from_cogitate_data(data:, data_coercer: default_data_coercer, **keywords)
        cogitate_agent = data_coercer.call(data: data)
        Sipity::Models::AuthenticationAgent::FromCogitate.new(cogitate_agent: cogitate_agent, **keywords)
      end

      Contract(None => Sipity::Interfaces::AuthenticationAgentInterface)
      def self.new_null_agent
        Sipity::Models::AuthenticationAgent::NullAgent.new
      end

      Contract(
        KeywordArgs[identifiable_agent: Sipity::Interfaces::IdentifiableAgentInterface] => Sipity::Interfaces::AuthenticationAgentInterface
      )
      def self.new_from_identifiable_agent(identifiable_agent:)
        new(identifiable_agent: identifiable_agent) do
          self.ids = [identifiable_agent.identifier_id]
        end
      end

      Contract(
        KeywordArgs[
          strategy: String, identifying_value: String, builder: Optional[RespondTo[:new_with_strategy_and_identifying_value]]
        ] => Sipity::Interfaces::AuthenticationAgentInterface
      )
      def self.new_from_strategy_and_identifying_value(strategy:, identifying_value:, builder: IdentifiableAgent)
        identifiable_agent = builder.new_with_strategy_and_identifying_value(strategy: strategy, identifying_value: identifying_value)
        new_from_identifiable_agent(identifiable_agent: identifiable_agent)
      end

      def self.default_token_decoder
        Cogitate::Client.method(:extract_agent_from)
      end
      private_class_method :default_token_decoder

      def self.default_data_coercer
        Cogitate::Client::DataToObjectCoercer
      end
      private_class_method :default_token_decoder

      def initialize(identifiable_agent:, &block)
        self.identifiable_agent = identifiable_agent
        instance_exec(&block) if block_given?
        self.ids = [] unless ids.present?
        freeze
        ids.freeze
      end

      delegate :identifier_id, :strategy, :identifying_value, to: :identifiable_agent

      attr_reader :email, :signed_in, :name, :ids, :agreed_to_application_terms_of_service
      alias_method :signed_in?, :signed_in
      alias_method :agreed_to_application_terms_of_service?, :agreed_to_application_terms_of_service
      alias_method :to_identifier_id, :identifier_id

      private

      attr_writer :email, :signed_in, :ids, :agreed_to_application_terms_of_service
      attr_accessor :identifiable_agent
    end
  end
end
