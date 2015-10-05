module Sipity
  module Models
    class IdentifiableAgent
      def self.new_from_collaborator(collaborator:)
        attributes = { name: collaborator.name, identifier_id: collaborator.identifier_id }
        attributes[:email] = collaborator.netid.present? ? "#{collaborator.netid}@nd.edu" : collaborator.email
        new(**attributes)
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
