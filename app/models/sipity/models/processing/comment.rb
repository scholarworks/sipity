module Sipity
  module Models
    module Processing
      # Responsible for capturing a :comment made by a given :actor on a given
      # :entity at a given :originating_strategy_state as part of a given
      # :originating_strategy_action.
      class Comment < ActiveRecord::Base
        self.table_name = 'sipity_processing_comments'

        belongs_to :actor, class_name: 'Sipity::Models::Processing::Actor'
        belongs_to :entity, class_name: 'Sipity::Models::Processing::Entity'
        belongs_to :originating_strategy_action, class_name: 'Sipity::Models::Processing::StrategyAction'
        belongs_to :originating_strategy_state, class_name: 'Sipity::Models::Processing::StrategyState'
      end
    end
  end
end
