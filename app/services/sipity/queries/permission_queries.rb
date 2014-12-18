module Sipity
  module Queries
    # Queries
    module PermissionQueries
      module_function

      def emails_for_associated_users(roles:, entity:)
        scope_users_by_entity_and_roles(roles: roles, entity: entity).pluck(:email)
      end
      public :emails_for_associated_users

      # Responsible for returning a User scope:
      # That will include all users
      # That have one or more roles
      # In which the user has a direction relation to the entity
      # Or in which a relation to the entity can be inferred by group membership
      #
      # If no roles are given, no entities will be returned.
      #
      # @param roles [Array<String>]
      # @param entity [ActiveRecord::Base]
      #
      # @return ActiveRecord::Relation
      #
      # @note Welcome to the land of AREL.
      # @see https://github.com/rails/arel AREL - A Relational Algebra
      def scope_users_by_entity_and_roles(roles:, entity:, user_class: User, group_class: Models::Group)
        user_table = user_class.arel_table
        perm_table = Models::Permission.arel_table
        memb_table = Models::GroupMembership.arel_table

        subqyery_user_relation_entity = perm_table.project(perm_table[:actor_id]).where(
          perm_table[:actor_type].eq(user_class.base_class).
          and(perm_table[:role].in(roles)).
          and(perm_table[:entity_type].eq(entity.class.base_class)).
          and(perm_table[:entity_id].eq(entity.to_key))
        )

        subquery_user_relation_to_entity_by_group_membership = memb_table.project(memb_table[:user_id]).where(
          memb_table[:user_id].in(
            perm_table.project(perm_table[:actor_id]).where(
              perm_table[:actor_type].eq(group_class.base_class).
              and(perm_table[:role].in(roles)).
              and(perm_table[:entity_type].eq(entity.class.base_class)).
              and(perm_table[:entity_id].eq(entity.to_key))
            )
          )
        )
        user_class.where(
          user_table[:id].in(subquery_user_relation_to_entity_by_group_membership).
          or(user_table[:id].in(subqyery_user_relation_entity))
        )
      end
      public :scope_users_by_entity_and_roles

      # Responsible for returning a scope for the entity type:
      # That match the given :entity_type
      # And for which the given :user has at least one of the given :roles.
      #
      # If no roles are given, no entities will be returned.
      #
      # @param user [User]
      # @param roles [Array<String>]
      # @param entity_type [Class]
      #
      # @return ActiveRecord::Relation
      #
      # @note Welcome to the land of AREL.
      # @see https://github.com/rails/arel AREL - A Relational Algebra
      def scope_permission_resolver(entity_type:, user:, roles:)
        perm_table = Models::Permission.arel_table
        memb_table = Models::GroupMembership.arel_table
        group_class =  Models::Group

        subquery_entity_relation_to_user = perm_table.project(perm_table[:entity_id]).where(
          perm_table[:actor_id].eq(user.to_key).
          and(perm_table[:actor_type].eq(user.class.base_class)).
          and(perm_table[:role].in(roles)).
          and(perm_table[:entity_type].eq(entity_type.base_class))
        )

        subquery_entity_relation_to_user_by_group_membership = perm_table.project(perm_table[:entity_id]).where(
          perm_table[:role].in(roles).
          and(perm_table[:entity_type].eq(entity_type.base_class)).
          and(perm_table[:actor_type].eq(group_class.base_class)).
          and(perm_table[:actor_id].in(memb_table.project(memb_table[:group_id]).where(memb_table[:user_id].eq(user.to_key))))
        )

        entity_type.where(
          entity_type.arel_table[:id].in(subquery_entity_relation_to_user).
          or(entity_type.arel_table[:id].in(subquery_entity_relation_to_user_by_group_membership))
        )
      end
      public :scope_permission_resolver
    end
  end
end
