module Sipity
  module Models
    module Processing
      # A named action that, during the processing of an entity, may be taken.
      class StrategyEvent < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_events'
        belongs_to :strategy
        belongs_to :resulting_strategy_state, class_name: 'StrategyState'

        has_many :entity_event_registers, dependent: :destroy

        has_many :strategy_actions, dependent: :destroy
        has_many :guarding_strategy_event_prerequisites,
          dependent: :destroy,
          foreign_key: :prerequisite_strategy_event_id,
          class_name: 'Sipity::Models::Processing::StrategyEventPrerequisite'

        has_many :requiring_strategy_event_prerequisites,
          dependent: :destroy,
          foreign_key: :guarded_strategy_event_id,
          class_name: 'Sipity::Models::Processing::StrategyEventPrerequisite'

        has_many :guards_these_strategy_events,
          through: :guarding_strategy_event_prerequisites,
          class_name: 'Sipity::Models::Processing::StrategyEvent'

        has_many :requires_these_strategy_events,
          through: :requiring_strategy_event_prerequisites,
          class_name: 'Sipity::Models::Processing::StrategyEvent'
      end
    end
  end
end
