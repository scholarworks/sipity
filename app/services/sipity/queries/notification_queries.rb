module Sipity
  module Queries
    # Queries
    module NotificationQueries
      def emails_for_associated_users(roles:, entity:, user_class: User, group_class: Models::Group)
        user_table = User.arel_table
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
        resolver = user_class.where(
          user_table[:id].in(group_permission_query).
          or(user_table[:id].in(user_permission_query))
        )
        resolver.pluck(:email)
      end
    end
  end
end
