module Sipity
  module Queries
    module ProcessingQueries
      include Conversions::ConvertToProcessingEntity
      def available_processing_events_for(user:, entity:)
        processing_actors = scope_for_processing_actors_from_user(user: user)
        entity = convert_to_processing_entity(entity)
      end

      def scope_for_processing_actors_from_user(user:)
        user_table = User.arel_table
        memb_table = Models::GroupMembership.arel_table
        actor_table = Models::Processing::Actor.arel_table

        group_polymorphic_type = Conversions::ConvertToPolymorphicType.call(Models::Group)
        user_polymorphic_type = Conversions::ConvertToPolymorphicType.call(User)

        user_contraints = actor_table[:proxy_for_type].eq(user_polymorphic_type).
          and(actor_table[:proxy_for_id].eq(user.id))
        group_constraints = actor_table[:proxy_for_type].eq(group_polymorphic_type).
          and(actor_table[:proxy_for_id].in(memb_table.project(memb_table[:group_id]).where(memb_table[:user_id].eq(user.id))))
        # Because AND takes precedence over OR, this query works.
        # WHERE (a AND b OR c AND d) == WHERE (a AND b) OR (c AND d)
        Models::Processing::Actor.where(user_contraints.or(group_constraints))
      end
    end
  end
end
