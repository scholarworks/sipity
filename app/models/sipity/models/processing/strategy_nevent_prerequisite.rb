module Sipity
  module Models
    module Processing
      class StrategyNeventPrerequisite < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_action_prerequisites'
        belongs_to :prerequisite_strategy_action, class_name: 'StrategyNevent'
        belongs_to :guarded_strategy_action, class_name: 'StrategyNevent'
      end
    end
  end
end
