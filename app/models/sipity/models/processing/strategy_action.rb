module Sipity
  module Models
    module Processing
      # A named thing that "happens" to a processing entity.
      class StrategyAction < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_actions'
        default_scope { order(:presentation_sequence) }
        belongs_to :strategy
        belongs_to :resulting_strategy_state, class_name: 'StrategyState'

        has_many :entity_action_registers, dependent: :destroy

        has_many :strategy_state_actions, dependent: :destroy

        has_many(
          :notifiable_contexts,
          dependent: :destroy,
          as: :scope_for_notification,
          class_name: 'Sipity::Models::Notification::NotifiableContext'
        )

        has_many(
          :guarding_strategy_action_prerequisites,
          dependent: :destroy,
          foreign_key: :prerequisite_strategy_action_id,
          class_name: 'Sipity::Models::Processing::StrategyActionPrerequisite'
        )

        has_many(
          :requiring_strategy_action_prerequisites,
          dependent: :destroy,
          foreign_key: :guarded_strategy_action_id,
          class_name: 'Sipity::Models::Processing::StrategyActionPrerequisite'
        )

        has_many(
          :processing_comments,
          foreign_key: :originating_strategy_action_id,
          dependent: :destroy,
          class_name: 'Sipity::Models::Processing::Comment'
        )

        has_many(
          :base_element_for_strategy_actions_analogues,
          foreign_key: :strategy_action_id,
          dependent: :destroy,
          class_name: 'Sipity::Models::Processing::StrategyActionAnalogue'
        )

        has_many(
          :analog_element_for_strategy_actions_analogues,
          foreign_key: :analogous_to_strategy_action_id,
          dependent: :destroy,
          class_name: 'Sipity::Models::Processing::StrategyActionAnalogue'
        )

        ENRICHMENT_ACTION = 'enrichment_action'.freeze
        RESOURCEFUL_ACTION = 'resourceful_action'.freeze
        STATE_ADVANCING_ACTION = 'state_advancing_action'.freeze

        enum(
          action_type: {
            ENRICHMENT_ACTION => ENRICHMENT_ACTION,
            RESOURCEFUL_ACTION => RESOURCEFUL_ACTION,
            STATE_ADVANCING_ACTION => STATE_ADVANCING_ACTION
          }
        )

        after_initialize :set_action_type, if: :new_record?

        RESOURCEFUL_ACTION_NAMES = %w(new create show edit update destroy debug).freeze

        # A magical action that for starting a submission in a submission window but creating a work
        # Both the submission window and the work processing strategies have a start_a_submission to
        # indicate how things get moving.
        START_A_SUBMISSION = 'start_a_submission'.freeze

        include Conversions::ConvertToProcessingActionName
        def name=(value)
          super(convert_to_processing_action_name(value))
        end

        def default_action_type
          if resulting_strategy_state_id.present?
            STATE_ADVANCING_ACTION
          elsif resulting_strategy_state.present?
            STATE_ADVANCING_ACTION
          elsif RESOURCEFUL_ACTION_NAMES.include?(name)
            RESOURCEFUL_ACTION
          else
            ENRICHMENT_ACTION
          end
        end

        private

        def set_action_type
          return true if action_type.present?
          self.action_type = default_action_type
        end
      end
    end
  end
end
