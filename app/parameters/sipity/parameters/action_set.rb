module Sipity
  module Parameters
    # Responsible for providing an identified collection of actions.
    class ActionSet
      def initialize(identifier:, collection:)
        self.identifier = identifier
        self.collection = collection
      end

      attr_reader :identifier, :collection

      private

      attr_writer :identifier, :collection
    end
  end
end
