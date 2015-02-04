module Sipity
  module Models
    module Processing
      class StrategyEventPrerequisite < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_nevent_prerequisites'
        belongs_to :prerequisite_strategy_nevent, class_name: 'StrategyEvent'
        belongs_to :guarded_strategy_nevent, class_name: 'StrategyEvent'
      end
    end
  end
end
