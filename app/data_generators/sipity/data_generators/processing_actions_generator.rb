module Sipity
  module DataGenerators
    # Responsible for generating the processing actions as defined in the action configuration
    class ProcessingActionsGenerator
      # A convenience method for constructing and calling this function.
      def self.call(**keywords, &block)
        new(**keywords, &block).call
      end

      def initialize(strategy:, actions_configuration:)
        self.strategy = strategy
        self.actions_configuration = actions_configuration
      end

      private

      attr_accessor :strategy

      attr_reader :actions_configuration

      def actions_configuration=(input)
        @actions_configuration = Array.wrap(input)
      end

      public

      def call
        generate_state_diagram!
        strategy
      end

      private

      def generate_state_diagram!
        actions_configuration.each do |configuration|
          Array.wrap(configuration.fetch(:name)).each do |name|
            DataGenerators::StateMachineGenerator.generate_from_schema(strategy: strategy, name: name, **configuration.except(:name))
          end
        end
      end
    end
  end
end
