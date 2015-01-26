require 'sipity/forms/work_enrichments'

module Sipity
  module Queries
    # Queries
    module EnrichmentQueries
      def build_enrichment_form(attributes = {})
        enrichment_type = attributes.fetch(:enrichment_type)
        builder = Forms::WorkEnrichments.find_enrichment_form_builder(enrichment_type: enrichment_type)
        builder.new(attributes)
      end

      def are_all_of_the_required_todo_items_done_for_work?(work:, work_processing_state: work.processing_state)
        current_todo_item_states_for(
          entity: work, work_type: work.work_type, work_processing_state: work_processing_state, enrichment_group: 'required'
        ).all? { |config_for_item_state| config_for_item_state.enrichment_state == 'done'}
      end

      # See http://www.slideshare.net/camerondutro/advanced-arel-when-activerecord-just-isnt-enough
      #   Slide #150
      def current_todo_item_states_for(entity:, work_type:, enrichment_group:, work_processing_state:)
        states = Models::TodoItemState.arel_table
        configs = Models::WorkTypeTodoListConfig.arel_table
        entity_id = entity.id
        entity_type = Conversions::ConvertToPolymorphicType.call(entity)

        state_configs = configs.join(states, Arel::Nodes::OuterJoin).on(
          states[:enrichment_type].eq(configs[:enrichment_type]).
          and(states[:entity_processing_state].eq(configs[:work_processing_state]))
        ).join_sources

        Models::WorkTypeTodoListConfig.
          select(configs[:enrichment_type], states[:enrichment_state], configs[:work_processing_state]).
        where(
          configs[:enrichment_group].eq(enrichment_group).
          and(configs[:work_processing_state].eq(work_processing_state)).
        and(configs[:work_type].eq(work_type))).
        where(
          states[:entity_id].eq(entity_id).
          and(states[:entity_type].eq(entity_type)).
          or(states[:entity_id].eq(nil))
        ).
          joins(state_configs)
      end
      private :current_todo_item_states_for

      def todo_list_for_current_processing_state_of_work(work:, processing_state: work.processing_state)
        # TODO: Can I tease apart the collaborator? I'd like to send a builder object
        # as a parameter. It would ease the entaglement that is happening here.
        Decorators::TodoList.new(entity: work) do |list|
          Models::TodoItemState.where(entity: work, entity_processing_state: processing_state).each do |todo_item|
            # REVIEW: Why is this the 'required' set; It should be based on something else.
            # For now, however, it stands.
            list.add_to(set: 'required', name: todo_item.enrichment_type, state: todo_item.enrichment_state)
          end
        end
      end
      module_function :todo_list_for_current_processing_state_of_work
      public :todo_list_for_current_processing_state_of_work
    end
  end
end
