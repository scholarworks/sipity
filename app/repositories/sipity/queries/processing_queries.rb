require 'active_support/core_ext/array/wrap'

module Sipity
  module Queries
    # Welcome intrepid developer. You have stumbled into some complex data
    # interactions. There are a lot of data collaborators regarding these tests.
    # I would love this to be more in isolation, but that is not in the cards as
    # there are at least 16 database tables interacting to ultimately answer the
    # following question:
    #
    # * What actions can a given user take on an entity?
    #
    # Could there be more efficient queries? Yes. However, the composition of
    # queries has proven to be a very powerful means of understanding and
    # exploring the problem.
    #
    # @note There is an indication of public or private api. The intent of this
    #   is to differentiate what are methods that are the primary entry points
    #   as understood as of the commit that has the @api tag. However, these are
    #   public methods because they have been tested in isolation and are used
    #   to help compose the `@api public` methods.
    module ProcessingQueries
      # @api public
      #
      # This query returns a unique set of state names that are associated
      # with one or more object (of usage_type) for the given work area.
      #
      # @example
      #   Given work area WA
      #   And given work type WT1 and WT2 are in WA.
      #   And WT1 has strategy states with names SS1, SS2, SS3
      #   And WT2 has strategy states with names SS1, SS2, SS4
      #   When we call #processing_state_names_for_select_within_work_area(work_area: WA)
      #   Then we will get back action names: [SS1, SS2, SS3, SS4]
      #
      # @param work_area [Object] that can be converted into a Sipity::Models::WorkArea
      # @param usage_type [Object] the polymorphic type for database storage
      #
      # @return [Array<String>] name of actions available
      def processing_state_names_for_select_within_work_area(work_area:, usage_type: Sipity::Models::WorkType)
        work_area = PowerConverter.convert(work_area, to: :work_area)
        usage_type = Conversions::ConvertToPolymorphicType.call(usage_type)

        strategy_states = Models::Processing::StrategyState.arel_table
        strategy_usages = Models::Processing::StrategyUsage.arel_table
        submission_window_work_types = Models::SubmissionWindowWorkType.arel_table
        submission_windows = Models::SubmissionWindow.arel_table

        select_manager = strategy_states.project(strategy_states[:name]).order(strategy_states[:name]).distinct.join(strategy_usages).on(
          strategy_usages[:strategy_id].eq(strategy_states[:strategy_id]).and(
            strategy_usages[:usage_type].eq(usage_type)
          )
        ).join(submission_window_work_types).on(
          submission_window_work_types[:work_type_id].eq(strategy_usages[:usage_id])
        ).join(submission_windows).on(
          submission_windows[:id].eq(submission_window_work_types[:submission_window_id]).and(
            submission_windows[:work_area_id].eq(work_area.id)
          )
        )

        Models::Processing::StrategyState.from(strategy_states.create_table_alias(select_manager, strategy_states.table_name)).pluck(:name)
      end

      # @api public
      #
      # Identifier associated with the given :entity and how they are associated with the given enitity.
      #
      # @param entity [Object] that can be converted into a Sipity::Models::Processing::Entity
      # @param role [Object] that can be converted into a Sipity::Models::Role
      # @return [Array<#identifier_id, #permission_grant_level>]
      def identifier_ids_associated_with_entity_and_role(entity:, role:)
        Queries::Complex::AgentsAssociatedWithEntity::RoleIdentifierFinder.all_for(entity: entity, role: role)
      end

      # @api public
      #
      # Roles associated with the given :entity
      # @param entity [Object] that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Role>]
      def scope_roles_associated_with_the_given_entity(entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        strategy_roles = Models::Processing::StrategyRole.arel_table
        Models::Role.where(
          Models::Role.arel_table[:id].in(
            strategy_roles.project(strategy_roles[:role_id]).where(
              strategy_roles[:strategy_id].eq(entity.strategy_id)
            )
          )
        )
      end

      # @api public
      #
      # Is the user authorized to take the processing action on the given
      # entity?
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @param action an object that can be converted into a Sipity::Models::Processing::StrategyAction#name
      # @return [Boolean]
      def authorized_for_processing?(user:, entity:, action:)
        action_name = Conversions::ConvertToProcessingActionName.call(action)
        scope_permitted_strategy_actions_available_for_current_state(user: user, entity: entity).
          where(Models::Processing::StrategyAction.arel_table[:name].eq(action_name)).count > 0
      end

      # @api private
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * Any user that has taken the action (or someone has taken it on their
      #   behalf)
      # * Any user that is part of a group that has taken the action (you know,
      #   because maybe we'll allow groups to take the action)
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @param action an object that can be covnerted into a Sipity::Models::Processing::Action
      #   given the entity
      # @return [ActiveRecord::Relation<User>]
      def users_that_have_taken_the_action_on_the_entity(entity:, actions:)
        users = User.arel_table
        group_memberships = Models::GroupMembership.arel_table

        User.where(
          users[:id].in(
            action_registers_subquery_builder(
              poly_type: User, entity: entity, actions: actions
            )
          ).or(
            users[:id].in(
              group_memberships.project(group_memberships[:user_id]).where(
                group_memberships[:group_id].in(
                  action_registers_subquery_builder(
                    poly_type: Sipity::Models::Group, entity: entity, actions: actions
                  )
                )
              )
            )
          )
        )
      end
      deprecate :users_that_have_taken_the_action_on_the_entity

      def action_registers_subquery_builder(poly_type:, entity:, actions:)
        actors = Models::Processing::Actor.arel_table
        action_registers = Models::Processing::EntityActionRegister.arel_table
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Array.wrap(actions) { |an_action| Conversions::ConvertToProcessingAction.call(an_action, scope: entity) }
        poly_type = Conversions::ConvertToPolymorphicType.call(poly_type)

        actors.project(actors[:proxy_for_id]).where(
          actors[:proxy_for_type].eq(poly_type)
        ).join(action_registers).on(
          action_registers[:on_behalf_of_actor_id].eq(actors[:id])
        ).where(
          action_registers[:strategy_action_id].in(actions.map(&:id)).
          and(action_registers[:entity_id].eq(entity.id))
        )
      end
      private :action_registers_subquery_builder
      deprecate :action_registers_subquery_builder

      # @api private
      def non_user_collaborators_that_have_taken_the_action_on_the_entity(entity:, actions:)
        Models::Collaborator.where(
          Models::Collaborator.arel_table[:id].in(
            action_registers_subquery_builder(poly_type: Models::Collaborator, entity: entity, actions: actions)
          )
        )
      end
      private :non_user_collaborators_that_have_taken_the_action_on_the_entity
      deprecate :non_user_collaborators_that_have_taken_the_action_on_the_entity

      # @api public
      #
      # Given the :entity and :action generate a ActiveRecord::Relation that
      # meets the following criteria:
      #
      # * A user has taken the action
      # * Someone has taken an action on behalf of a collaborator
      # * Somehow a group has taken an action so return all users
      #
      # @note This stretches out of the processing subsystem and out into the
      #   modeling; It highlights that the domain model has two concepts that
      #   are not properly being teased apart.
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @param action an object that can be covnerted into a Sipity::Models::Processing::Action
      #   given the entity
      # @return [ActiveRecord::Relation<User>]
      def collaborators_that_have_taken_the_action_on_the_entity(entity:, actions:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        collaborators = Models::Collaborator.arel_table
        users = User.arel_table
        users_scope = users_that_have_taken_the_action_on_the_entity(entity: entity, actions: actions)
        non_user_collaborator_scope = non_user_collaborators_that_have_taken_the_action_on_the_entity(entity: entity, actions: actions)

        Models::Collaborator.where(
          collaborators[:netid].in(
            users.project(
              users[:username]
            ).where(
              users_scope.constraints.reduce.and(collaborators[:netid].not_eq(nil))
            )
          ).or(
            collaborators[:id].in(
              Models::Collaborator.arel_table.project(
                non_user_collaborator_scope.arel_table[:id]
              ).where(
                non_user_collaborator_scope.constraints.reduce
              )
            )
          )
        ).where(
          collaborators[:work_id].eq(entity.proxy_for_id).and(
            collaborators[:responsible_for_review].eq(true)
          )
        )
      end
      deprecate :collaborators_that_have_taken_the_action_on_the_entity

      # @api public
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * Any unguarded actions
      # * Any guarded action that has had all of its prerequisites completed
      # * Only actions permitted to the user
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      def scope_permitted_strategy_actions_available_for_current_state(user:, entity:)
        strategy_actions_scope = scope_strategy_actions_available_for_current_state(entity: entity)
        strategy_state_actions_scope = scope_permitted_entity_strategy_state_actions(user: user, entity: entity)
        strategy_actions_scope.where(
          strategy_actions_scope.arel_table[:id].in(
            strategy_state_actions_scope.arel_table.project(
              strategy_state_actions_scope.arel_table[:strategy_action_id]
            ).where(strategy_state_actions_scope.constraints.reduce)
          )
        )
      end

      # @api public
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * Actions that are permitted to the current user
      # * Actions that are available for the entity's current state.
      #
      # AND
      #
      # * Actions that are permitted to be taken multiple times within the
      #   current state OR
      # * Actions that are not allowed to be taken multiple times and have not
      #   yet been taken.
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      def scope_permitted_entity_strategy_actions_for_current_state(user:, entity:)
        action_scope = scope_permitted_without_concern_for_repetition_entity_strategy_actions_for_current_state(user: user, entity: entity)

        entity = Conversions::ConvertToProcessingEntity.call(entity)
        agent = PowerConverter.convert(user, to: :agent)
        registers = Models::Processing::EntityActionRegister.arel_table
        analogues = Models::Processing::StrategyActionAnalogue.arel_table

        actions_that_have_not_occurred_for_the_actor = action_scope.arel_table.project(
          action_scope.arel_table[:id]
        ).join(
          registers, Arel::Nodes::OuterJoin
        ).on(
          registers[:entity_id].eq(entity.id).and(
            registers[:on_behalf_of_identifier_id].in(agent.ids)
          ).and(
            registers[:strategy_action_id].eq(action_scope.arel_table[:id])
          )
        ).where(
          registers[:strategy_action_id].eq(nil).and(
            action_scope.arel_table[:allow_repeat_within_current_state].eq(false)
          )
        )

        # TODO: This is presently broken up into two queries. It could be
        # consolidated into a single query with a left outer join.
        permitted_ids = action_scope.where(
          action_scope.arel_table[:allow_repeat_within_current_state].eq(true).or(
            action_scope.arel_table[:id].in(
              actions_that_have_not_occurred_for_the_actor
            )
          )
        ).pluck(:id)

        # I have a list of permitted ids. I need to eliminate from the list any
        # ids that have analogs not in the list. However I should keep any ids
        # that can be repeated for a given state.
        action_scope.klass.where(id: permitted_ids).where(
          action_scope.arel_table[:id].not_in(
            analogues.project(
              analogues[:strategy_action_id]
            ).where(
              analogues[:analogous_to_strategy_action_id].not_in(permitted_ids).and(
                analogues[:analogous_to_strategy_action_id].not_eq(analogues[:strategy_action_id])
              )
            )
          ).or(action_scope.arel_table[:allow_repeat_within_current_state].eq(true))
        )
      end

      # @api private
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * Actions that are permitted to the current user
      # * Actions that are available for the entity's current state.
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      def scope_permitted_without_concern_for_repetition_entity_strategy_actions_for_current_state(user:, entity:)
        strategy_actions = Models::Processing::StrategyAction

        strategy_actions_for_current_state_scope = scope_strategy_actions_for_current_state(entity: entity)
        strategy_state_actions_scope = scope_permitted_entity_strategy_state_actions(user: user, entity: entity)

        strategy_actions.where(
          strategy_actions.arel_table[:id].in(
            strategy_state_actions_scope.arel_table.project(
              strategy_state_actions_scope.arel_table[:strategy_action_id]
            ).where(
              strategy_state_actions_scope.constraints.reduce
            )
          ).and(
            strategy_actions.arel_table[:id].in(
              strategy_actions_for_current_state_scope.arel_table.project(
                strategy_actions_for_current_state_scope.arel_table[:id]
              ).where(
                strategy_actions_for_current_state_scope.constraints.reduce
              )
            )
          )
        )
      end
      private :scope_permitted_without_concern_for_repetition_entity_strategy_actions_for_current_state

      # @api public
      #
      # This method crosses the boundary out of the processing subsystem to
      # return an ActiveRecord::Relation scope of the objects that are proxied
      # by the processing system. The returned scope will returng objects that
      # meet the following criteria:
      #
      # * Processing Entities of the given proxy_for_type
      # * Processing Entities in a state in which I have access to based on:
      #   - The entity specific responsibility
      #     - For which I've been assigned either as a group member or a user
      #   - The strategy specific responsibility
      #     - For which I've been assigned either as a group member or a user
      #
      # @param [User] user
      # @param proxy_for_type something that can be converted to a polymorphic
      #   type.
      # @param [Hash] filter
      # @option filter [String] :processing_state - Limit the returned objects
      #   to those objects that are in the named :processing_state
      # @param [Hash] query_criteria
      # @option query_criteria [Hash] :where - A where clause to evaluate against
      #   the ActiveRecord::Relation
      # @option query_criteria [String,Array] :order - An order clause to evaluate against
      #   the ActiveRecord::Relation
      # @option query_criteria [Integer] :page - A page value to apply pagination
      #   to the query
      #
      # @return [ActiveRecord::Relation<proxy_for_types>]
      def scope_proxied_objects_for_the_user_and_proxy_for_type(user:, proxy_for_type:, filter: {}, **query_criteria)
        proxy_for_type = Conversions::ConvertToPolymorphicType.call(proxy_for_type)
        scope = scope_processing_entities_for_the_user_and_proxy_for_type(
          user: user, proxy_for_type: proxy_for_type, filter: filter
        )

        scope = proxy_for_type.where(
          proxy_for_type.arel_table[proxy_for_type.primary_key].in(scope.entity).or(
            proxy_for_type.arel_table[proxy_for_type.primary_key].in(scope.strategy)
          )
        )
        if query_criteria.key?(:where)
          scope = scope.where(query_criteria.fetch(:where))
        end

        if query_criteria.key?(:order)
          scope = scope.order(query_criteria.fetch(:order))
        end

        if query_criteria.key?(:page)
          scope = scope.page(query_criteria.fetch(:page))
        end
        scope
      end

      PermissionScope = Struct.new(:entity, :strategy)
      private_constant :PermissionScope

      # @api private
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * Processing Entities of the given proxy_for_type
      # * Processing Entities in a state in which I have access to based on:
      #   - The entity specific responsibility
      #     - For which I've been assigned either as a group member or a user
      #   - The strategy specific responsibility
      #     - For which I've been assigned either as a group member or a user
      #
      # In other words, for the given user and the given proxy for type (i.e.
      # Models::Work), fetch all of the processing entities that I can, in some
      # way, access based on the processing state.
      #
      # @param [User] user
      # @param proxy_for_type something that can be converted to a polymorphic
      #   type.
      # @param [Hash] filter
      # @option filter [String] :processing_state - Limit the returned objects
      #   to those objects that are in the named :processing_state
      #
      # @return [ActiveRecord::Relation<Models::Processing::Entity>]
      def scope_processing_entities_for_the_user_and_proxy_for_type(user:, proxy_for_type:, filter: {})
        proxy_for_type = Conversions::ConvertToPolymorphicType.call(proxy_for_type)

        entities = Models::Processing::Entity.arel_table
        strategy_state_actions = Models::Processing::StrategyStateAction.arel_table
        strategy_states = Models::Processing::StrategyState.arel_table
        strategy_state_action_permissions = Models::Processing::StrategyStateActionPermission.arel_table
        strategy_responsibilities = Models::Processing::StrategyResponsibility.arel_table
        entity_responsibilities = Models::Processing::EntitySpecificResponsibility.arel_table

        agent = PowerConverter.convert(user, to: :agent)

        join_builder = lambda do |responsibility|
          entities.project(
            entities[:proxy_for_id]
          ).join(strategy_state_actions).on(
            strategy_state_actions[:originating_strategy_state_id].eq(entities[:strategy_state_id])
          ).join(strategy_state_action_permissions).on(
            strategy_state_action_permissions[:strategy_state_action_id].eq(strategy_state_actions[:id])
          ).join(strategy_states).on(
            strategy_states[:id].eq(strategy_state_actions[:originating_strategy_state_id])
          ).join(responsibility).on(
            responsibility[:strategy_role_id].eq(strategy_state_action_permissions[:strategy_role_id])
          )
        end

        where_builder = lambda do |responsibility|
          returning = entities[:proxy_for_type].eq(proxy_for_type).and(
            responsibility[:identifier_id].in(agent.ids)
          )
          processing_state = filter[:processing_state]
          if processing_state.present?
            returning = returning.and(
              entities[:strategy_state_id].in(
                strategy_states.project(strategy_states[:id]).where(
                  strategy_states[:name].eq(processing_state)
                )
              )
            )
          end
          returning
        end

        entity_specific_joins = join_builder.call(entity_responsibilities)
        strategy_specific_joins = join_builder.call(strategy_responsibilities)

        entity_specific_where = where_builder.call(entity_responsibilities).and(
          entities[:id].eq(entity_responsibilities[:entity_id])
        )
        strategy_specific_where = where_builder.call(strategy_responsibilities)

        PermissionScope.new(
          entity_specific_joins.where(entity_specific_where),
          strategy_specific_joins.where(strategy_specific_where)
        )
      end
      private :scope_processing_entities_for_the_user_and_proxy_for_type

      # @api public
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * Users that are directly associated with the given entity through on or
      #   more of the given roles
      # * Users that are indirectly associated with the given entity by group
      #   and role.
      #
      # @param roles [Sipity::Models::Role]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<User>]
      #
      # @todo Replace with query against Cogitate
      def scope_users_for_entity_and_roles(entity:, roles:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        role_ids = Array.wrap(roles).map { |role| Conversions::ConvertToRole.call(role).id }
        group_polymorphic_type = Conversions::ConvertToPolymorphicType.call(Models::Group)
        user_polymorphic_type = Conversions::ConvertToPolymorphicType.call(User)

        strategy_roles = Models::Processing::StrategyRole.arel_table
        strategy_responsibilities = Models::Processing::StrategyResponsibility.arel_table
        entity_responsibilities = Models::Processing::EntitySpecificResponsibility.arel_table
        user_table = User.arel_table
        actor_table = Models::Processing::Actor.arel_table
        memb_table = Models::GroupMembership.arel_table

        strategy_role_id_subquery = strategy_roles.project(strategy_roles[:id]).where(
          strategy_roles[:role_id].in(role_ids)
        )

        strategy_actor_id_subquery = strategy_responsibilities.project(strategy_responsibilities[:actor_id]).where(
          strategy_responsibilities[:strategy_role_id].in(strategy_role_id_subquery)
        )

        entity_actor_id_subquery = entity_responsibilities.project(entity_responsibilities[:actor_id]).where(
          entity_responsibilities[:strategy_role_id].in(strategy_role_id_subquery).
          and(entity_responsibilities[:entity_id].eq(entity.id))
        )

        sub_query_for_user = actor_table.project(actor_table[:proxy_for_id]).where(
          actor_table[:id].in(strategy_actor_id_subquery).
          or(actor_table[:id].in(entity_actor_id_subquery))
        ).where(
          actor_table[:proxy_for_type].eq(user_polymorphic_type)
        )

        sub_query_for_user_via_group = memb_table.project(memb_table[:user_id]).where(
          memb_table[:group_id].in(
            actor_table.project(actor_table[:proxy_for_id]).where(
              actor_table[:id].in(strategy_actor_id_subquery).
              or(actor_table[:id].in(entity_actor_id_subquery))
            ).where(
              actor_table[:proxy_for_type].eq(group_polymorphic_type)
            )
          )
        )

        User.where(
          user_table[:id].in(sub_query_for_user).
          or(user_table[:id].in(sub_query_for_user_via_group))
        )
      end
      deprecate :scope_users_for_entity_and_roles

      def scope_creating_users_for_entity(entity:, roles: Models::Role::CREATING_USER)
        Complex::AgentsAssociatedWithEntity.enumerator_for(entity: entity, roles: roles)
      end

      def user_emails_for_entity_and_roles(entity:, roles:)
        Complex::AgentsAssociatedWithEntity.emails_for(entity: entity, roles: roles)
      end

      # @api public
      #
      # For the given :user and :entity, return an ActiveRecord::Relation that,
      # if resolved, will be all of the assocated strategy roles for both the
      # strategy responsibilities and the entity specific responsibilities.
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyRole>]
      def scope_processing_strategy_roles_for_user_and_entity(user:, entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        strategy_scope = scope_processing_strategy_roles_for_user_and_strategy(user: user, strategy: entity.strategy)

        entity_specific_scope = scope_processing_strategy_roles_for_user_and_entity_specific(user: user, entity: entity)
        Models::Processing::StrategyRole.where(
          strategy_scope.arel.constraints.reduce.or(entity_specific_scope.arel.constraints.reduce)
        )
      end

      # @api private
      #
      # For the given :user and :strategy, return an ActiveRecord::Relation that,
      # if resolved, will be all of the assocated strategy roles that are
      # assigned to directly to the strategy.
      #
      # @param user [User]
      # @param strategy [Processing::Strategy]
      # @return [ActiveRecord::Relation<Models::Processing::StrategyRole>]
      def scope_processing_strategy_roles_for_user_and_strategy(user:, strategy:)
        responsibility_table = Models::Processing::StrategyResponsibility.arel_table
        strategy_role_table = Models::Processing::StrategyRole.arel_table

        agent = PowerConverter.convert(user, to: :agent)
        strategy_role_subquery = strategy_role_table[:id].in(
          responsibility_table.project(responsibility_table[:strategy_role_id]).
          where(
            responsibility_table[:identifier_id].in(agent.ids)
          )
        )

        Models::Processing::StrategyRole.where(
          strategy_role_table[:strategy_id].eq(strategy.id).and(strategy_role_subquery)
        )
      end

      # @api private
      #
      # For the given :user and :entity, return an ActiveRecord::Relation that,
      # if resolved, will be all of the assocated strategy roles that are
      # assigned to specifically to the entity (and not the parent strategy).
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyRole>]
      def scope_processing_strategy_roles_for_user_and_entity_specific(user:, entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        agent = PowerConverter.convert(user, to: :agent)
        specific_resp_table = Models::Processing::EntitySpecificResponsibility.arel_table
        strategy_role_table = Models::Processing::StrategyRole.arel_table

        Models::Processing::StrategyRole.where(
          strategy_role_table[:id].in(
            specific_resp_table.project(specific_resp_table[:strategy_role_id]).
            where(
              specific_resp_table[:identifier_id].in(agent.ids).and(specific_resp_table[:entity_id].eq(entity.id))
            )
          )
        )
      end

      # @api private
      #
      # For the given :user and :entity, return an ActiveRecord::Relation,
      # that if resolved, will be collection of
      # Sipity::Models::Processing::StrategyStateAction object to which the user has
      # permission to do something.
      #
      # An ActiveRecord::Relation scope that meets the following criteria:
      #
      # * The actions are available for the given entity's current state
      # * The actions are available for the given user based on their role.
      #   Either:
      #   - Directly via an actor associated with a user
      #   - Indirectly via an actor associated with a group
      #
      # @param user [User]
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyStateAction>]
      def scope_permitted_entity_strategy_state_actions(user:, entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        strategy_state_actions = Models::Processing::StrategyStateAction
        permissions = Models::Processing::StrategyStateActionPermission
        role_scope = scope_processing_strategy_roles_for_user_and_entity(user: user, entity: entity)

        strategy_state_actions.where(
          strategy_state_actions.arel_table[:originating_strategy_state_id].eq(entity.strategy_state_id).and(
            strategy_state_actions.arel_table[:id].in(
              permissions.arel_table.project(
                permissions.arel_table[:strategy_state_action_id]
              ).where(
                permissions.arel_table[:strategy_role_id].in(
                  role_scope.arel_table.project(role_scope.arel_table[:id]).where(
                    role_scope.arel.constraints.reduce
                  )
                )
              )
            )
          )
        )
      end
      private :scope_permitted_entity_strategy_state_actions

      # @api private
      #
      # For the given :entity return an ActiveRecord::Relation that when
      # resolved will be only the strategy actions that:
      #
      # * Have prerequisites
      # * And all of those prerequisites have been completed
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      def scope_strategy_actions_with_completed_prerequisites(entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Models::Processing::StrategyAction
        action_prereqs = Models::Processing::StrategyActionPrerequisite
        actions_that_occurred = scope_statetegy_actions_that_have_occurred(entity: entity)
        completed_guarded_actions_subquery = action_prereqs.arel_table.project(
          action_prereqs.arel_table[:guarded_strategy_action_id]
        ).where(
          action_prereqs.arel_table[:prerequisite_strategy_action_id].in(
            actions_that_occurred.arel_table.project(actions_that_occurred.arel_table[:id]).
            where(actions_that_occurred.arel.constraints.reduce)
          )
        )
        actions.where(
          actions.arel_table[:strategy_id].eq(entity.strategy_id).
          and(actions.arel_table[:id].in(completed_guarded_actions_subquery))
        )
      end

      # @api private
      #
      # For the given :entity return an ActiveRecord::Relation that when
      # resolved will be only the strategy actions that:
      #
      # * Has at least one prerequisite
      # * And at least one of those prerequisites is incomplete
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @param pluck a list of column names to pluck from the query
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      # @return [Array] if a pluck is given
      def scope_strategy_actions_with_incomplete_prerequisites(entity:, pluck: nil)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Models::Processing::StrategyAction
        prerequisites = Models::Processing::StrategyActionPrerequisite.arel_table
        registers = Models::Processing::EntityActionRegister.arel_table

        incomplete_prerequisites_subquery = prerequisites.project(prerequisites[:guarded_strategy_action_id]).join(
          registers, Arel::Nodes::OuterJoin
        ).on(
          registers[:entity_id].eq(entity.id).and(
            registers[:strategy_action_id].eq(prerequisites[:prerequisite_strategy_action_id])
          )
        ).where(registers[:strategy_action_id].eq(nil))

        unplucked = actions.where(
          actions.arel_table[:strategy_id].eq(entity.strategy_id).and(
            actions.arel_table[:id].in(incomplete_prerequisites_subquery)
          )
        )
        return unplucked unless pluck.present?
        unplucked.pluck(pluck)
      end

      # @api private
      #
      # For the given :entity, return an ActiveRecord::Relation, that if
      # resolved, that is only the strategy actions that have no prerequisites.
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      def scope_strategy_actions_without_prerequisites(entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Models::Processing::StrategyAction
        action_prereqs = Models::Processing::StrategyActionPrerequisite

        actions.where(
          actions.arel_table[:strategy_id].eq(entity.strategy_id).
          and(
            actions.arel_table[:id].not_in(
              action_prereqs.arel_table.project(
                action_prereqs.arel_table[:guarded_strategy_action_id]
              )
            )
          )
        )
      end

      # @api public
      #
      # For the given :entity return an ActiveRecord::Relation that when
      # resolved will be only the strategy actions that:
      #
      # * Are available for the entity's strategy_state
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      def scope_strategy_actions_for_current_state(entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Models::Processing::StrategyAction
        state_actions_table = Models::Processing::StrategyStateAction.arel_table
        actions.where(
          actions.arel_table[:id].in(
            state_actions_table.project(state_actions_table[:strategy_action_id]).
            where(state_actions_table[:originating_strategy_state_id].eq(entity.strategy_state_id))
          )
        )
      end

      # @api public
      #
      # For the given :entity return an ActiveRecord::Relation that when
      # resolved will be only the strategy actions that:
      #
      # * Are prerequisites for one or more other actions
      # * Are actions associated with the entity's processing strategy
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @param pluck a list of column names to pluck from the query
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>] if no pluck is given
      # @return [Array] if a pluck is given
      def scope_strategy_actions_that_are_prerequisites(entity:, pluck: nil)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Models::Processing::StrategyAction
        prerequisite_actions = Models::Processing::StrategyActionPrerequisite.arel_table
        unplucked = actions.where(
          actions.arel_table[:id].in(
            prerequisite_actions.project(prerequisite_actions[:prerequisite_strategy_action_id])
          ).and(actions.arel_table[:strategy_id].eq(entity.strategy_id))
        )
        return unplucked unless pluck.present?
        unplucked.pluck(pluck)
      end

      # @api private
      #
      # For the given :entity, return an ActiveRecord::Relation, that if
      # resolved, that is only the strategy actions that have occurred.
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @param pluck a list of column names to pluck from the query
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>] if no pluck is given
      # @return [Array] if a pluck is given
      def scope_statetegy_actions_that_have_occurred(entity:, pluck: nil)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        actions = Models::Processing::StrategyAction
        register = Models::Processing::EntityActionRegister

        unplucked = actions.where(
          actions.arel_table[:strategy_id].eq(entity.strategy_id).
          and(
            actions.arel_table[:id].in(
              register.arel_table.project(register.arel_table[:strategy_action_id]).
              where(register.arel_table[:entity_id].eq(entity.id))
            )
          )
        )
        return unplucked unless pluck.present?
        unplucked.pluck(pluck)
      end

      # @api private
      #
      # For the given :entity, return an ActiveRecord::Relation, that
      # if resolved, that lists all of the actions available for the entity and
      # its current state.
      #
      # * All actions that are associated with actions that do not have prerequsites
      # * All actions that have prerequisites and all of those prerequisites are complete
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @return [ActiveRecord::Relation<Models::Processing::StrategyAction>]
      def scope_strategy_actions_available_for_current_state(entity:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        strategy_actions_without_prerequisites = scope_strategy_actions_without_prerequisites(entity: entity)
        strategy_actions_with_completed_prerequisites = scope_strategy_actions_with_completed_prerequisites(entity: entity)
        strategy_actions_for_current_state = scope_strategy_actions_for_current_state(entity: entity)
        actions = Models::Processing::StrategyAction
        actions.where(
          strategy_actions_without_prerequisites.constraints.reduce.and(
            strategy_actions_for_current_state.constraints.reduce
          ).or(
            strategy_actions_with_completed_prerequisites.constraints.reduce.and(
              strategy_actions_for_current_state.constraints.reduce
            )
          )
        )
      end
    end
  end
end
