module Sipity
  module Models
    module Processing
      # Who can trigger this event?
      class StrategyActionPermission < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_action_permissions'
        belongs_to :strategy_role
        belongs_to :strategy_action
      end
    end
  end
end
