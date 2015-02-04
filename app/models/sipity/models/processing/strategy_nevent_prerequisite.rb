module Sipity
  module Models
    module Processing
      class StrategyNeventPrerequisite < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_nevent_prerequisites'
        belongs_to :prerequisite_strategy_nevent, class_name: 'StrategyNevent'
        belongs_to :guarded_strategy_nevent, class_name: 'StrategyNevent'
      end
    end
  end
end
