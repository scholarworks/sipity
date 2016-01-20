module Sipity
  module Services
    # Service object that handles the business logic of granting permission at the entity level.
    #
    # @todo Consider how this would look with strategy level as well.
    class ProcessingPermissionHandler
      # @api public
      def self.grant(entity:, actor:, role:)
        new(entity: entity, identifiable: actor, role: role).grant
      end

      # @api public
      def self.revoke(entity:, actor:, role:)
        new(entity: entity, identifiable: actor, role: role).revoke
      end

      def initialize(entity:, identifiable:, role:)
        self.entity = entity
        self.identifiable = identifiable
        self.role = role
      end
      attr_reader :entity, :identifiable, :role
      alias identifier_id identifiable

      delegate :strategy, to: :entity

      def grant
        with_valid_strategy_role do |strategy_role|
          create_entity_specific_responsibility(strategy_role: strategy_role) unless strategy_role_responsibility_exists?
        end
        true
      end

      def revoke
        with_valid_strategy_role do |strategy_role|
          destroy_entity_specific_responsibility(strategy_role: strategy_role)
        end
        true
      rescue Exceptions::ValidProcessingStrategyRoleNotFoundError
        # REVIEW: Should there be any reporting on this?
        true
      end

      private

      def with_valid_strategy_role
        strategy_role = Models::Processing::StrategyRole.find_by!(strategy_id: strategy.id, role_id: role.id)
        yield(strategy_role)
      rescue ActiveRecord::RecordNotFound => exception
        raise Exceptions::ValidProcessingStrategyRoleNotFoundError, exception.message
      end

      def create_entity_specific_responsibility(strategy_role:)
        Models::Processing::EntitySpecificResponsibility.find_or_create_by!(
          strategy_role_id: strategy_role.id, entity_id: entity.id, identifier_id: identifier_id
        )
      end

      def destroy_entity_specific_responsibility(strategy_role:)
        Models::Processing::EntitySpecificResponsibility.where(
          strategy_role_id: strategy_role.id, entity_id: entity.id, identifier_id: identifier_id
        ).destroy_all
      end

      def strategy_role_responsibility_exists?
        Models::Processing::StrategyRole.where(
          role_id: role.id, strategy_id: strategy.id
        ).joins(:strategy_responsibilities).any?
      end

      include Conversions::ConvertToProcessingEntity
      def entity=(object)
        @entity = convert_to_processing_entity(object)
      end

      def identifiable=(object)
        @identifiable = PowerConverter.convert_to_identifier_id(object)
      end

      include Conversions::ConvertToRole
      def role=(object)
        @role = convert_to_role(object)
      end
    end
  end
end
