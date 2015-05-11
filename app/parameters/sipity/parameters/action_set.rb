module Sipity
  module Parameters
    # Responsible for providing an identified collection of actions.
    class ActionSet
      def initialize(identifier:, collection:, entity:)
        self.identifier = identifier
        self.collection = collection
        self.entity = entity
      end

      delegate :any?, :present?, :empty?, to: :collection

      attr_reader :identifier, :collection, :entity

      private

      attr_writer :identifier, :entity

      def collection=(input)
        @collection = Array.wrap(input)
      end
    end
  end
end
