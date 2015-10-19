module Sipity
  module Models
    # A data structure class for identifiable agents.
    class IdentifiableAgent
      def self.new_from_collaborator(collaborator:)
        attributes = { name: collaborator.name, identifier_id: collaborator.identifier_id }
        attributes[:email] = collaborator.netid.present? ? "#{collaborator.netid}@nd.edu" : collaborator.email
        new(**attributes)
      end

      def self.new_from_user(user:)
        identifier_id = Cogitate::Client.encoded_identifier_for(strategy: 'netid', identifying_value: user.username)
        new(name: user.name, email: "#{user.username}@nd.edu", identifier_id: identifier_id)
      end

      def self.new_from_netid(netid:)
        new_with_strategy_and_identifying_value(strategy: 'netid', identifying_value: netid)
      end

      def self.new_for_identifier_id(identifier_id:)
        strategy, identifying_value = Cogitate::Client.extract_strategy_and_identifying_value(identifier_id)
        email = extract_email_from(strategy: strategy, identifying_value: identifying_value)
        new(identifier_id: identifier_id, name: identifying_value, email: email)
      end

      def self.new_with_strategy_and_identifying_value(strategy:, identifying_value:)
        identifier_id = Cogitate::Client.encoded_identifier_for(strategy: strategy, identifying_value: identifying_value)
        email = extract_email_from(strategy: strategy, identifying_value: identifying_value)
        new(identifier_id: identifier_id, name: identifying_value, email: email, strategy: strategy, identifying_value: identifying_value)
      end

      def self.extract_email_from(strategy:, identifying_value:)
        return identifying_value if strategy == 'email'
        return "#{identifying_value}@nd.edu" if strategy == 'netid'
        nil
      end
      private_class_method :extract_email_from

      # Yup. Keeping this data structure's new method private. Use one of the above builder methods.
      private_class_method :new

      def initialize(identifier_id:, name:, email:, **keywords)
        self.identifier_id = identifier_id
        self.name = name
        self.email = email
        self.strategy = keywords.fetch(:strategy) { default_strategy_from_identifier }
        self.identifying_value = keywords.fetch(:identifying_value) { default_identifying_value_from_identifier }
      end

      attr_reader :identifier_id, :name, :email, :strategy, :identifying_value
      alias_method :to_s, :name

      alias_method :to_identifier_id, :identifier_id

      private

      attr_writer :identifier_id, :name, :email, :strategy, :identifying_value

      def default_strategy_from_identifier
        Cogitate::Client.extract_strategy_and_identifying_value(identifier_id).first
      end

      def default_identifying_value_from_identifier
        Cogitate::Client.extract_strategy_and_identifying_value(identifier_id).last
      end
    end
  end
end
