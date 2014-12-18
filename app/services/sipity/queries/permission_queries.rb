module Sipity
  module Queries
    # Queries
    module PermissionQueries
      module_function

      def emails_for_associated_users(roles:, entity:)
        find_users_by_entity_and_roles(roles: roles, entity: entity).pluck(:email)
      end
      public :emails_for_associated_users

      def find_users_by_entity_and_roles(roles:, entity:, user_class: User, group_class: Models::Group)
        user_table = user_class.arel_table
        perm_table = Models::Permission.arel_table
        memb_table = Models::GroupMembership.arel_table

        group_permission_query = memb_table.project(memb_table[:user_id]).where(
          memb_table[:user_id].in(
            perm_table.project(perm_table[:actor_id]).where(
              perm_table[:actor_type].eq(group_class.base_class).
              and(perm_table[:role].in(roles)).
              and(perm_table[:entity_type].eq(entity.class.base_class)).
              and(perm_table[:entity_id].eq(entity.to_key))
            )
          )
        )
        user_permission_query = perm_table.project(perm_table[:actor_id]).where(
          perm_table[:actor_type].eq(user_class.base_class).
          and(perm_table[:role].in(roles)).
          and(perm_table[:entity_type].eq(entity.class.base_class)).
          and(perm_table[:entity_id].eq(entity.to_key))
        )
        user_class.where(
          user_table[:id].in(group_permission_query).
          or(user_table[:id].in(user_permission_query))
        )
      end
      public :find_users_by_entity_and_roles

      # Responsible for returning a list of enitites:
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

        user_permission_subquery = perm_table.project(perm_table[:entity_id]).where(
          perm_table[:actor_id].eq(user.to_key).
          and(perm_table[:actor_type].eq(user.class.base_class)).
          and(perm_table[:role].in(roles)).
          and(perm_table[:entity_type].eq(entity_type.base_class))
        )

        group_permission_subquery = perm_table.project(perm_table[:entity_id]).where(
          perm_table[:role].in(roles).
          and(perm_table[:entity_type].eq(entity_type.base_class)).
          and(perm_table[:actor_type].eq(Models::Group.base_class)).
          and(perm_table[:actor_id].in(memb_table.project(memb_table[:group_id]).where(memb_table[:user_id].eq(user.to_key))))
        )
        entity_type.where(
          entity_type.arel_table[:id].in(user_permission_subquery).
          or(entity_type.arel_table[:id].in(group_permission_subquery))
        )
      end
      public :scope_permission_resolver
    end
  end
end
