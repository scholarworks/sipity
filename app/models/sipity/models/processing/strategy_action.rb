module Sipity
  module Models
    module Processing
      # A named thing that "happens" to a processing entity.
      class StrategyAction < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_actions'
        belongs_to :strategy
        belongs_to :resulting_strategy_state, class_name: 'StrategyState'

        has_many :entity_action_registers, dependent: :destroy

        has_many :strategy_state_actions, dependent: :destroy
        has_many :guarding_strategy_action_prerequisites,
          dependent: :destroy,
          foreign_key: :prerequisite_strategy_action_id,
          class_name: 'Sipity::Models::Processing::StrategyActionPrerequisite'

        has_many :requiring_strategy_action_prerequisites,
          dependent: :destroy,
          foreign_key: :guarded_strategy_action_id,
          class_name: 'Sipity::Models::Processing::StrategyActionPrerequisite'

        has_many :guards_these_strategy_actions,
          through: :guarding_strategy_action_prerequisites,
          class_name: 'Sipity::Models::Processing::StrategyAction'

        has_many :requires_these_strategy_actions,
          through: :requiring_strategy_action_prerequisites,
          class_name: 'Sipity::Models::Processing::StrategyAction'

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

        RESOURCEFUL_ACTION_NAMES = %w(new create show edit update destroy).freeze

        private

        def set_action_type
          return true if action_type.present?
          if resulting_strategy_state_id.present?
            self.action_type = STATE_ADVANCING_ACTION
          elsif resulting_strategy_state.present?
            self.action_type = STATE_ADVANCING_ACTION
          elsif RESOURCEFUL_ACTION_NAMES.include?(name)
            self.action_type = RESOURCEFUL_ACTION
          else
            self.action_type = ENRICHMENT_ACTION
          end
        end
      end
    end
  end
end
