require 'active_support/core_ext/array/wrap'

require 'sipity/guard_interface_expectation'

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

      include GuardInterfaceExpectation
      def entity=(input)
        guard_interface_expectation!(input, :processing_state)
        @entity = input
      end
    end
  end
end
