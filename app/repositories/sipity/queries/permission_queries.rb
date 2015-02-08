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

      def deprecated_emails_for_associated_users(acting_as:, entity:)
        scope_users_by_entity_and_acting_as(acting_as: acting_as, entity: entity).pluck(:email)
      end
      module_function :deprecated_emails_for_associated_users
      public :deprecated_emails_for_associated_users

      def can_the_user_act_on_the_entity?(user:, acting_as:, entity:)
        scope_users_for_entity_and_roles(entity: entity, roles: acting_as).
          where(id: user.id).any?
      end

      def deprecate_can_the_user_act_on_the_entity?(user:, acting_as:, entity:)
        scope_users_by_entity_and_acting_as(acting_as: acting_as, entity: entity).
          where(User.arel_table[:id].eq(user.id)).count > 0
      end

      def available_event_triggers_for(user:, entity:)
        scope_permitted_strategy_actions_available_for_current_state(user: user, entity: entity).pluck(:name)
      end

      def deprecated_available_event_triggers_for(user:, entity:)
        acting_as = user_can_act_as_the_following_on_entity(user: user, entity: entity)
        diagram = StateMachines.state_diagram_for(work_type: entity.work_type)
        diagram.available_events_for_when_acting_as(current_state: entity.processing_state, acting_as: acting_as)
      end

      # @return Array<String> of acting_as
      def user_can_act_as_the_following_on_entity(user:, entity:)
        scope_acting_as_by_entity_and_user(user: user, entity: entity).pluck(:acting_as)
      end

      # Given a user and entity, return all of the permissions by:
      #
      # * Direct user association
      # * Indirect user association via group membership
      #
      # @param user [User]
      # @param entity [ActiveRecord::Base]
      #
      # @return ActiveRecord::Relation
      #
      # @note Welcome to the land of AREL.
      def scope_acting_as_by_entity_and_user(user:, entity:)
        perm_table = Models::Permission.arel_table
        memb_table = Models::GroupMembership.arel_table
        user_id = user.id
        entity_id = entity.id
        entity_polymorphic_type = Conversions::ConvertToPolymorphicType.call(entity)
        group_polymorphic_type = Conversions::ConvertToPolymorphicType.call(Models::Group)
        user_polymorphic_type = Conversions::ConvertToPolymorphicType.call(user)

        group_ids_for_user_subquery = memb_table.project(memb_table[:group_id]).where(
          memb_table[:user_id].eq(user_id)
        )

        Models::Permission.distinct.where(
          perm_table[:entity_id].eq(entity_id).
          and(perm_table[:entity_type].eq(entity_polymorphic_type))
        ).where(
          (
            perm_table[:actor_type].eq(user_polymorphic_type).
            and(perm_table[:actor_id].eq(user_id))
          ).
          or(
            perm_table[:actor_type].eq(group_polymorphic_type).
            and(perm_table[:actor_id].in(group_ids_for_user_subquery))
          )
        )
      end
      module_function :scope_acting_as_by_entity_and_user
      public :scope_acting_as_by_entity_and_user

      # Responsible for returning a User scope:
      # That will include all users
      # That have one or more acting_as
      # In which the user has a direction relation to the entity
      # Or in which a relation to the entity can be inferred by group membership
      #
      # If no acting_as are given, no entities will be returned.
      #
      # @param acting_as [Array<String>]
      # @param entity [ActiveRecord::Base]
      #
      # @return ActiveRecord::Relation
      #
      # @note Welcome to the land of AREL.
      # @see https://github.com/rails/arel AREL - A Relational Algebra
      def scope_users_by_entity_and_acting_as(acting_as:, entity:)
        user_table = User.arel_table
        perm_table = Models::Permission.arel_table
        memb_table = Models::GroupMembership.arel_table
        entity_id = entity.id

        entity_polymorphic_type = Conversions::ConvertToPolymorphicType.call(entity)
        group_polymorphic_type = Conversions::ConvertToPolymorphicType.call(Models::Group)
        user_polymorphic_type = Conversions::ConvertToPolymorphicType.call(User)

        subquery_user_relation_entity = perm_table.project(perm_table[:actor_id]).where(
          perm_table[:actor_type].eq(user_polymorphic_type).
          and(perm_table[:acting_as].in(acting_as)).
          and(perm_table[:entity_type].eq(entity_polymorphic_type)).
          and(perm_table[:entity_id].eq(entity_id))
        )

        subquery_user_relation_to_entity_by_group_membership = memb_table.project(memb_table[:user_id]).where(
          memb_table[:user_id].in(
            perm_table.project(perm_table[:actor_id]).where(
              perm_table[:actor_type].eq(group_polymorphic_type).
              and(perm_table[:acting_as].in(acting_as)).
              and(perm_table[:entity_type].eq(entity_polymorphic_type)).
              and(perm_table[:entity_id].eq(entity_id))
            )
          )
        )
        User.where(
          user_table[:id].in(subquery_user_relation_to_entity_by_group_membership).
          or(user_table[:id].in(subquery_user_relation_entity))
        )
      end
      module_function :scope_users_by_entity_and_acting_as
      public :scope_users_by_entity_and_acting_as

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
      module_function :scope_entities_for_entity_type_and_user_acting_as
      public :scope_entities_for_entity_type_and_user_acting_as
    end
  end
end
