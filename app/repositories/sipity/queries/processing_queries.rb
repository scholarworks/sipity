module Sipity
  module Queries
    module ProcessingQueries
      include Conversions::ConvertToProcessingEntity
      def available_processing_events_for(user:, entity:)
        processing_actors = scope_processing_actors_for(user: user)
        entity = convert_to_processing_entity(entity)
      end

      def scope_processing_actors_for(user:)
        user_table = User.arel_table
        memb_table = Models::GroupMembership.arel_table
        actor_table = Models::Processing::Actor.arel_table

        group_polymorphic_type = Conversions::ConvertToPolymorphicType.call(Models::Group)
        user_polymorphic_type = Conversions::ConvertToPolymorphicType.call(User)

        user_constraints = actor_table[:proxy_for_type].eq(user_polymorphic_type).
          and(actor_table[:proxy_for_id].eq(user.id))
        group_constraints = actor_table[:proxy_for_type].eq(group_polymorphic_type).
          and(actor_table[:proxy_for_id].in(memb_table.project(memb_table[:group_id]).where(memb_table[:user_id].eq(user.id))))
        # Because AND takes precedence over OR, this query works.
        # WHERE (a AND b OR c AND d) == WHERE (a AND b) OR (c AND d)
        Models::Processing::Actor.where(user_constraints.or(group_constraints))
      end

      def scope_processing_strategy_roles_for(user:, strategy:)
        responsibility_table = Models::Processing::StrategyResponsibility.arel_table
        strategy_role_table = Models::Processing::StrategyRole.arel_table

        actor_constraints = scope_processing_actors_for(user: user)
        strategy_role_subquery = strategy_role_table[:id].in(
          responsibility_table.project(responsibility_table[:strategy_role_id]).
          where(
            responsibility_table[:actor_id].in(
              actor_constraints.arel_table.project(
                actor_constraints.arel_table[:id]
              ).where(actor_constraints.arel.constraints)
            )
          )
        )

        Models::Processing::StrategyRole.where(
          strategy_role_table[:strategy_id].eq(strategy.id).and(strategy_role_subquery)
        )
      end

      def scope_custom_processing_strategy_roles_for_user_and_entity(user:, entity:)
        actor_constraints = scope_processing_actors_for(user: user)
        specific_resp_table = Models::Processing::EntitySpecificResponsibility.arel_table
        strategy_role_table = Models::Processing::StrategyRole.arel_table

        Models::Processing::StrategyRole.where(
          strategy_role_table[:id].in(
            specific_resp_table.project(specific_resp_table[:strategy_role_id]).
            where(
              specific_resp_table[:actor_id].in(
                actor_constraints.arel_table.project(
                  actor_constraints.arel_table[:id]
                ).where(
                  actor_constraints.arel.constraints.reduce.and(specific_resp_table[:entity_id].eq(entity.id)))
              )
            )
          )
        )
      end
    end
  end
end
