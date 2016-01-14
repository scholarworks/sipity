require 'active_support/core_ext/array/wrap'

module Sipity
  # :nodoc:
  module DataGenerators
    # A "power users" helper class. It builds out the permissions for a host of
    # information.
    #
    # See the specs for more on what is happening, however the general idea is
    # to encapsulate the logic of assigning :actors to the :role either for
    # the :entity or the :strategy. Then creating the given :action_names for
    # the :strategy and :strategy_state and granting permission in that
    # :strategy_state for the given :role.
    class PermissionGenerator
      def self.call(**keywords, &block)
        new(**keywords, &block).call
      end

      def initialize(roles:, strategy:, actors: [], **keywords)
        self.roles = roles
        self.strategy = strategy
        self.identifier_ids = actors
        self.entity = keywords.fetch(:entity) if keywords.key?(:entity)
        self.strategy_state = keywords.fetch(:strategy_state, false)
        self.action_names = keywords.fetch(:action_names, [])
        yield(self) if block_given?
      end

      private

      attr_accessor :strategy, :strategy_state
      attr_reader :entity, :identifier_ids, :action_names, :roles

      def identifier_ids=(input)
        @identifier_ids = Array.wrap(input).map { |i| PowerConverter.convert(i, to: :identifier_id) }
      end

      def action_names=(input)
        @action_names = Array.wrap(input)
      end

      def roles=(input)
        @roles = Array.wrap(input).map { |role| Conversions::ConvertToRole.call(role) }
      end

      def entity=(entity)
        @entity = Conversions::ConvertToProcessingEntity.call(entity)
      end

      public

      def call
        roles.each do |role|
          strategy_role = Models::Processing::StrategyRole.find_or_create_by!(role: role, strategy: strategy)
          associate_strategy_role_at_entity_level(strategy_role)
          associate_strategy_role_at_strategy_level(strategy_role)
          create_action_and_permission_for_actions(strategy_role)
        end
      end

      private

      def create_action_and_permission_for_actions(strategy_role)
        action_names.each do |action_name|
          create_action_and_permission_for(action_name, strategy_role)
        end
      end

      def create_action_and_permission_for(action_name, strategy_role)
        strategy_action = Models::Processing::StrategyAction.find_or_create_by!(strategy: strategy, name: action_name)
        return unless strategy_state.present?
        state_action = Models::Processing::StrategyStateAction.find_or_create_by!(
          strategy_action: strategy_action, originating_strategy_state: strategy_state
        )
        Models::Processing::StrategyStateActionPermission.
          find_or_create_by!(strategy_role: strategy_role, strategy_state_action: state_action)
      end

      def associate_strategy_role_at_strategy_level(strategy_role)
        return if entity
        identifier_ids.each do |identifier_id|
          Models::Processing::StrategyResponsibility.find_or_create_by!(strategy_role: strategy_role, identifier_id: identifier_id)
        end
      end

      def associate_strategy_role_at_entity_level(strategy_role)
        return unless entity
        identifier_ids.each do |identifier_id|
          Models::Processing::EntitySpecificResponsibility.find_or_create_by!(
            strategy_role: strategy_role, entity: entity, identifier_id: identifier_id
          )
        end
      end
    end
    private_constant :PermissionGenerator
  end
end
