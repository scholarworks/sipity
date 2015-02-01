module Sipity
  module Queries
    module ProcessingQueries
      include Conversions::ConvertToProcessingEntity
      def available_processing_events_for(user:, entity:)
        processing_actors = scope_processing_actors_for(user: user)
        entity = convert_to_processing_entity(entity)
      end

      # For the given user:, return an ActiveRecord::Relation, that if resolved,
      # will be all of the associated processing actors.
      #
      # @param user [User]
      # @return ActiveRecord::Relation<Models::Processing::Actor>
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

      # For the given :user and :entity, return an ActiveRecord::Relation that,
      # if resolved, will be all of the assocated strategy roles for both the
      # strategy responsibilities and the entity specific responsibilities.
      #
      # @param user [User]
      # @param entity [Processing::Entity]
      # @return ActiveRecord::Relation<Models::Processing::StrategyRole>
      def scope_processing_strategy_roles_for_user_and_entity(user:, entity:)
        entity = convert_to_processing_entity(entity)
        strategy_scope = scope_processing_strategy_roles_for(user: user, strategy: entity.strategy)
        entity_specific_scope = scope_entity_specific_processing_strategy_roles(user: user, entity: entity)
        strategy_role_table = Models::Processing::StrategyRole.arel_table
        Models::Processing::StrategyRole.where(
          strategy_scope.arel.constraints.reduce.or(entity_specific_scope.arel.constraints.reduce)
        )
      end

      # For the given :user and :strategy, return an ActiveRecord::Relation that,
      # if resolved, will be all of the assocated strategy roles that are
      # assigned to directly to the strategy.
      #
      # @param user [User]
      # @param entity [Processing::Strategy]
      # @return ActiveRecord::Relation<Models::Processing::StrategyRole>
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

      # For the given :user and :entity, return an ActiveRecord::Relation that,
      # if resolved, will be all of the assocated strategy roles that are
      # assigned to specifically to the entity (and not the parent strategy).
      #
      # @param user [User]
      # @param entity [Processing::Entity]
      # @return ActiveRecord::Relation<Models::Processing::StrategyRole>
      def scope_entity_specific_processing_strategy_roles(user:, entity:)
        entity = convert_to_processing_entity(entity)
        actor_scope = scope_processing_actors_for(user: user)
        specific_resp_table = Models::Processing::EntitySpecificResponsibility.arel_table
        strategy_role_table = Models::Processing::StrategyRole.arel_table

        Models::Processing::StrategyRole.where(
          strategy_role_table[:id].in(
            specific_resp_table.project(specific_resp_table[:strategy_role_id]).
            where(
              specific_resp_table[:actor_id].in(
                actor_scope.arel_table.project(
                  actor_scope.arel_table[:id]
                ).where(
                actor_scope.arel.constraints.reduce.and(specific_resp_table[:entity_id].eq(entity.id)))
              )
            )
          )
        )
      end
    end
  end
end
