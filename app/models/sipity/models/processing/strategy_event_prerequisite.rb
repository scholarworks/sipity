module Sipity
  module Models
    module Processing
      class StrategyEventPrerequisite < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_event_prerequisites'
        belongs_to :prerequisite_strategy_event, class_name: 'StrategyEvent'
        belongs_to :guarded_strategy_event, class_name: 'StrategyEvent'
      end
    end
  end
end
