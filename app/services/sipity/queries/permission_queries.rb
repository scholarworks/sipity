module Sipity
  module Queries
    # Queries
    module PermissionQueries
      module_function

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
        entity_type.where(
          entity_type.arel_table[:id].in(
            user_permission_subquery(user: user, roles: roles, entity_type: entity_type)
          ).or(
            entity_type.arel_table[:id].in(
              group_permission_subquery(user: user, roles: roles, entity_type: entity_type)
            )
          )
        )
      end
      public :scope_permission_resolver

      # Responsible for returning entity ids to which the user has direct
      # access.
      def user_permission_subquery(user:, roles:, entity_type:, perm_table: Models::Permission.arel_table)
        # For user based queries
        perm_table.project(perm_table[:entity_id]).where(
          perm_table[:actor_id].eq(user.to_key).
          and(perm_table[:actor_type].eq(user.class.base_class)).
          and(perm_table[:role].in(roles)).
          and(perm_table[:entity_type].eq(entity_type.base_class))
        )
      end
      private :user_permission_subquery

      # Responsible for returning entity ids to which the user has direct
      # inferred access based on group membership.
      def group_permission_subquery(user:, roles:, entity_type:, perm_table: Models::Permission.arel_table)
        perm_table.project(perm_table[:entity_id]).where(
          perm_table[:role].in(roles).
          and(perm_table[:entity_type].eq(entity_type.base_class)).
          and(perm_table[:actor_type].eq(Models::Group.base_class)).
          and(perm_table[:actor_id].in(user_group_membership_subquery(user: user)))
        )
      end
      private :group_permission_subquery

      # Responsible for returning group ids to which the user belongs.
      def user_group_membership_subquery(user:, membership_table: Models::GroupMembership.arel_table)
        membership_table.project(membership_table[:group_id]).
          where(membership_table[:user_id].eq(user.to_key))
      end
      private :user_group_membership_subquery
    end
  end
end
