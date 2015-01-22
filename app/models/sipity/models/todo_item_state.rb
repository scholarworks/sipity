module Sipity
  module Models
    # Responsible for persisting the state of a todo list item for a given
    # entity and its processing state.
    class TodoItemState < ActiveRecord::Base
      self.table_name = 'sipity_todo_item_states'
      belongs_to :entity, polymorphic: true

      ENRICHMENT_STATE_INCOMPLETE = 'incomplete'.freeze
      ENRICHMENT_STATE_DONE = 'done'.freeze

      # While this make look ridiculous, if I use an Array, the enum declaration
      # insists on persisting the value as the index instead of the key. While
      # this might make more sense from a storage standpoint, it is not as clear
      # and leverages a more opaque assumption.
      enum(
        enrichment_state: {
          ENRICHMENT_STATE_INCOMPLETE => ENRICHMENT_STATE_INCOMPLETE,
          ENRICHMENT_STATE_DONE => ENRICHMENT_STATE_DONE
        }
      )

      private

      after_initialize :set_initial_enrichment_state, if: :new_record?

      def set_initial_enrichment_state
        self.enrichment_state ||= ENRICHMENT_STATE_INCOMPLETE
      end
    end
  end
end
