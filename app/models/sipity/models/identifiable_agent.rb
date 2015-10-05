module Sipity
  module Models
    class IdentifiableAgent
      def self.new_from_collaborator(collaborator:)
        attributes = { name: collaborator.name, identifier_id: collaborator.identifier_id }
        attributes[:email] = collaborator.netid.present? ? "#{collaborator.netid}@nd.edu" : collaborator.email
        new(**attributes)
      end

      def self.new_for_identifier_id(identifier_id:)
        strategy, identifying_value = Cogitate::Client.extract_strategy_and_identifying_value(identifier_id)
        email = case strategy
        when 'email' then identifying_value
        when 'netid' then "#{identifying_value}@nd.edu"
        else nil
        end
        new(identifier_id: identifier_id, name: identifying_value, email: email)
      end

      private_class_method :new

      def initialize(identifier_id:, name:, email:)
        self.identifier_id = identifier_id
        self.name = name
        self.email = email
      end

      attr_reader :identifier_id, :name, :email
      alias_method :to_s, :name

      private

      attr_writer :identifier_id, :name, :email
    end
  end
end
