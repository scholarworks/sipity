module Sipity
  module Models
    module Processing
      # For a given event to happen, what are the pre-requisites?
      #
      # REVIEW: Should this be prerequisite event or action?
      class StrategyActionPrerequisite < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_action_prerequisites'
        belongs_to :prerequisite_strategy_action, class_name: 'StrategyAction'
        belongs_to :guarded_strategy_action, class_name: 'StrategyAction'
      end
    end
  end
end
