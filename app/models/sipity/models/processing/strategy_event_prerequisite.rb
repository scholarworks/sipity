module Sipity
  module Models
    module Processing
      # For a given event to happen, what are the pre-requisites?
      #
      # REVIEW: Should this be prerequisite event or action?
      class StrategyEventPrerequisite < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_event_prerequisites'
        belongs_to :prerequisite_strategy_event, class_name: 'StrategyEvent'
        belongs_to :guarded_strategy_event, class_name: 'StrategyEvent'
      end
    end
  end
end
