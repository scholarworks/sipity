module Sipity
  module Queries
    # Queries
    module PermissionQueries
      include ProcessingQueries
      def emails_for_associated_users(acting_as:, entity:)
        # TODO: Remove the singleton query method behavior. Its ridiculous! It
        #   infects everything. This is a major code stink.
        Queries::ProcessingQueries.scope_users_for_entity_and_roles(entity: entity, roles: acting_as).pluck(:email)
      end
      module_function :emails_for_associated_users
      public :emails_for_associated_users

      def can_the_user_act_on_the_entity?(user:, acting_as:, entity:)
        scope_users_for_entity_and_roles(entity: entity, roles: acting_as).
          where(id: user.id).any?
      end

      def available_event_triggers_for(user:, entity:)
        scope_permitted_strategy_actions_available_for_current_state(user: user, entity: entity).pluck(:name)
      end

      # Responsible for returning a scope for the entity type:
      # That match the given :entity_type
      # And for which the given :user has at least one of the given :acting_as.
      #
      # If no acting_as are given, no entities will be returned.
      #
      # @param user [User]
      # @param acting_as [Array<String>]
      # @param entity_type [Class]
      #
      # @return ActiveRecord::Relation
      #
      # @note Welcome to the land of AREL.
      # @see https://github.com/rails/arel AREL - A Relational Algebra
      def scope_entities_for_entity_type_and_user_acting_as(entity_type:, user:, acting_as:)
        return entity_type.where("0 = 1") unless user.present?
        perm_table = Models::Permission.arel_table
        memb_table = Models::GroupMembership.arel_table
        actor_id = user.id
        entity_polymorphic_type = Conversions::ConvertToPolymorphicType.call(entity_type)
        group_polymorphic_type = Conversions::ConvertToPolymorphicType.call(Models::Group)
        user_polymorphic_type = Conversions::ConvertToPolymorphicType.call(user)

        subquery_entity_relation_to_user = perm_table.project(perm_table[:entity_id]).where(
          perm_table[:actor_id].eq(actor_id).
          and(perm_table[:actor_type].eq(user_polymorphic_type)).
          and(perm_table[:acting_as].in(acting_as)).
          and(perm_table[:entity_type].eq(entity_polymorphic_type))
        )

        subquery_entity_relation_to_user_by_group_membership = perm_table.project(perm_table[:entity_id]).where(
          perm_table[:acting_as].in(acting_as).
          and(perm_table[:entity_type].eq(entity_polymorphic_type)).
          and(perm_table[:actor_type].eq(group_polymorphic_type)).
          and(perm_table[:actor_id].in(memb_table.project(memb_table[:group_id]).where(memb_table[:user_id].eq(actor_id))))
        )

        entity_type.where(
          entity_type.arel_table[:id].in(subquery_entity_relation_to_user).
          or(entity_type.arel_table[:id].in(subquery_entity_relation_to_user_by_group_membership))
        )
      end
    end
  end
end
