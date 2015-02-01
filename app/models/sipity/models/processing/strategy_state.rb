module Sipity
  module Models
    module Processing
      # Throughout the workflow process, a processed entity may have numerous
      # states.
      class StrategyState < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_states'
        belongs_to :strategy
        has_many(:originating_strategy_events,
          dependent: :destroy,
          class_name: 'StrategyEvent',
          foreign_key: :originating_strategy_event_id
        )
        has_many(:resulting_strategy_events,
          dependent: :destroy,
          class_name: 'StrategyEvent',
          foreign_key: :resulting_strategy_event_id
        )
        has_many(:entities)
      end
    end
  end
end
