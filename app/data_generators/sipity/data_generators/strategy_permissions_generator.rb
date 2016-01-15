module Sipity
  module DataGenerators
    # Responsible for generating the strategy permissions
    class StrategyPermissionsGenerator
      def self.call(**keywords)
        new(**keywords).call
      end

      def initialize(strategy:, strategy_permissions_configuration:)
        self.strategy = strategy
        self.strategy_permissions_configuration = strategy_permissions_configuration
      end

      private

      attr_accessor :strategy
      attr_reader :strategy_permissions_configuration

      def strategy_permissions_configuration=(input)
        @strategy_permissions_configuration = Array.wrap(input)
      end

      public

      def call
        find_or_create_strategy_permissions!
        strategy
      end

      private

      def find_or_create_strategy_permissions!
        strategy_permissions_configuration.each do |configuration|
          Array.wrap(configuration.fetch(:group)).each do |group_name|
            group = Models::Group.find_or_create_by!(name: group_name)
            PermissionGenerator.call(actors: group, roles: configuration.fetch(:role), strategy: strategy)
          end
        end
      end
    end
  end
end
