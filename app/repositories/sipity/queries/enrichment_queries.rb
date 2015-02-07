require 'sipity/forms/work_enrichments'

module Sipity
  module Queries
    # Queries
    module EnrichmentQueries
      # This is a refactoring step. Remove once processing queries are spliced
      # in.
      include Queries::ProcessingQueries

      def build_enrichment_form(attributes = {})
        enrichment_type = attributes.fetch(:enrichment_type)
        builder = Forms::WorkEnrichments.find_enrichment_form_builder(enrichment_type: enrichment_type)
        builder.new(attributes)
      end

      def are_all_of_the_required_todo_items_done_for_work?(work:)
        # TODO: Convert this into a single query instead of three queries.
        (
          scope_strategy_actions_for_current_state(entity: work).pluck(:id) -
          scope_strategy_actions_with_completed_prerequisites(entity: work).pluck(:id) -
          scope_strategy_actions_without_prerequisites(entity: work).pluck(:id)
        ).empty?
      end

      def deprecated_are_all_of_the_required_todo_items_done_for_work?(work:, work_processing_state: work.processing_state)
        # TODO: MAGIC STRINGS HERE!
        find_current_todo_item_states_for(
          entity: work, work_processing_state: work_processing_state, enrichment_group: 'required'
        ).all? { |config_for_item_state| config_for_item_state.enrichment_state == 'done' }
      end

      # Find all of the Possible Todo List Items for the given Entity
      # For each of the Possible Todo List Items, if there is a enrichment_state
      #   for that Entity's Todo Item, report that; Otherwise it is NULL.
      #
      # See http://www.slideshare.net/camerondutro/advanced-arel-when-activerecord-just-isnt-enough
      #   Slide #150
      def find_current_todo_item_states_for(options = {})
        entity = options.fetch(:entity)
        work_type = options.fetch(:work_type) { entity.work_type }
        enrichment_group = options.fetch(:enrichment_group) { nil }
        work_processing_state = options.fetch(:work_processing_state) { entity.processing_state }
        states = Models::TodoItemState.arel_table
        configs = Models::WorkTypeTodoListConfig.arel_table
        entity_id = entity.id
        entity_type = Conversions::ConvertToPolymorphicType.call(entity)

        state_configs = configs.join(states, Arel::Nodes::OuterJoin).on(
          states[:enrichment_type].eq(configs[:enrichment_type]).
          and(states[:entity_processing_state].eq(configs[:work_processing_state])).
          and(states[:entity_id].eq(entity_id)).
          and(states[:entity_type].eq(entity_type))
        ).join_sources

        base_where_clause = configs[:work_processing_state].eq(work_processing_state).and(configs[:work_type].eq(work_type))

        if enrichment_group
          base_where_clause = base_where_clause.and(configs[:enrichment_group].eq(enrichment_group))
        end

        Models::WorkTypeTodoListConfig.
          select(configs[:enrichment_group], configs[:enrichment_type], states[:enrichment_state], configs[:work_processing_state]).
          where(base_where_clause).
          joins(state_configs)
      end
      module_function :find_current_todo_item_states_for
      public :find_current_todo_item_states_for

      def todo_list_for_current_processing_state_of_work(work:)
        # TODO: Can I tease apart the collaborator? I'd like to send a builder object
        # as a parameter. It would ease the entaglement that is happening here.
        Decorators::TodoList.new(entity: work) do |list|
          # TODO: Splice these into a single query; Right now preserving outward behavior
          actions_that_are_prerequisites = scope_strategy_actions_that_are_prerequisites(entity: work).pluck(:id)
          completed_actions = scope_statetegy_actions_that_have_occurred(entity: work).pluck(:id)
          scope_strategy_actions_for_current_state(entity: work).where(action_type: 'enrichment_action').each do |action|
            list.add_to(
              set: actions_that_are_prerequisites.include?(action.id) ? 'required' : 'optional',
              name: action.name,
              state: completed_actions.include?(action.id) ? 'done' : Models::TodoItemState::ENRICHMENT_STATE_INCOMPLETE
            )
          end
        end
      end
      module_function :todo_list_for_current_processing_state_of_work
      public :todo_list_for_current_processing_state_of_work

      def deprecated_todo_list_for_current_processing_state_of_work(work:, processing_state: work.processing_state)
        # TODO: Can I tease apart the collaborator? I'd like to send a builder object
        # as a parameter. It would ease the entaglement that is happening here.
        Decorators::TodoList.new(entity: work) do |list|
          find_current_todo_item_states_for(entity: work, work_processing_state: processing_state).each do |todo_item|
            # TODO: LOW PRIORITY: The todo_item is a composite todo item based on the above query.
            list.add_to(
              set: todo_item.enrichment_group,
              name: todo_item.enrichment_type,
              state: todo_item.enrichment_state || Models::TodoItemState::ENRICHMENT_STATE_INCOMPLETE
            )
          end
        end
      end
      module_function :deprecated_todo_list_for_current_processing_state_of_work
      public :deprecated_todo_list_for_current_processing_state_of_work
    end
  end
end
