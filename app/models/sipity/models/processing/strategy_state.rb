module Sipity
  module Models
    module Processing
      # Throughout the workflow process, a processed entity may have numerous
      # states.
      class StrategyState < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_states'
        belongs_to :strategy
        has_many(:originating_strategy_actions,
          dependent: :destroy,
          class_name: 'StrategyAction',
          foreign_key: :originating_strategy_state_id
        )
        has_many(:resulting_strategy_nevents,
          dependent: :destroy,
          class_name: 'StrategyNevent',
          foreign_key: :resulting_strategy_state_id
        )
        has_many(:entities) # TODO: should this be destroyed
      end
    end
  end
end
