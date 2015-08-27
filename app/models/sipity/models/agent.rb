require 'sipity/interfaces'
require 'cogitate/client'

module Sipity
  module Models
    # The "current user" of application.
    class Agent
      DeviseBackedAgent = Struct.new(:name, :email, :ids, :user_id) do
        def user_signed_in?
          true
        end
      end

      NullAgent = Struct.new(:name, :email, :ids) do
        def user_signed_in?
          false
        end
      end

      include Contracts
      Contract(KeywordArgs[token: String, token_decoder: Optional[RespondTo[:call]]] => Sipity::Interfaces::AgentInterface)
      def self.new_from_cogitate_token(token:, token_decoder: default_token_decoder, **keywords)
        cogitate_agent = token_decoder.call(token: token)
        new(cogitate_agent, **keywords)
      end

      Contract(KeywordArgs[user_id: Or[String, Integer]] => Sipity::Interfaces::AgentInterface)
      def self.new_from_user_id(user_id:)
        user = User.find(user_id)
        ids = [Cogitate::Client.encoded_identifier_for(strategy: 'netid', identifying_value: user.username)]
        DeviseBackedAgent.new(user.to_s, user.email, ids, user.id)
      end

      Contract(None => Sipity::Interfaces::AgentInterface)
      def self.new_null_agent
        NullAgent.new
      end

      def self.default_token_decoder
        require 'cogitate/client/token_to_object_coercer' unless defined?(Cogitate::Client::TokenToObjectCoercer)
        Cogitate::Client::TokenToObjectCoercer
      end
      private_class_method :default_token_decoder

      # Yup, I'm privatizing the .new method. If you want an Agent use one of the custom new methods on this class.
      private_class_method :new

      def initialize(cogitate_agent, ids_decoder: default_ids_decoder)
        self.cogitate_agent = cogitate_agent
        self.ids_decoder = ids_decoder
      end

      def email
        cogitate_agent.with_emails.to_a.first
      end

      def user_signed_in?
        true
      end

      # A hack for Devise and actor conversions
      def netid
        return @netid if @netid
        ids.each do |id|
          ids_decoder.call(id).each do |identifier|
            next unless identifier.strategy == 'netid'
            @netid = identifier.identifying_value
          end
          break if @netid
        end
        @netid
      end

      delegate :ids, :name, to: :cogitate_agent

      private

      attr_accessor :cogitate_agent, :ids_decoder

      def default_ids_decoder
        require 'cogitate/services/identifiers_decoder' unless defined?(Cogitate::Services::IdentifiersDecoder)
        Cogitate::Services::IdentifiersDecoder
      end
    end
  end
end
