module Sipity
  module Parameters
    # Responsible for providing an identified collection of actions.
    class ActionSetParameter
      DEFAULT_IDENTIFIER = 'unknown'.freeze
      def initialize(collection:, entity:, identifier: DEFAULT_IDENTIFIER)
        self.identifier = identifier
        self.collection = collection
        self.entity = entity
      end

      delegate :any?, :present?, :empty?, to: :collection
      delegate :processing_state, to: :entity

      attr_reader :identifier, :collection, :entity

      private

      attr_writer :identifier

      def collection=(input)
        @collection = Array.wrap(input)
      end

      def entity=(input)
        guard_interface_expectation!(input, :processing_state)
        @entity = input
      end

      # TODO: Extract this as a service method
      def guard_interface_expectation!(input, *expectations)
        expectations.each do |expectation|
          fail(Exceptions::InterfaceExpectationError, object: input, expectation: expectation) unless input.respond_to?(expectation)
        end
      end
    end
  end
end
