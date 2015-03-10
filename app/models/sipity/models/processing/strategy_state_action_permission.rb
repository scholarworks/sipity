module Sipity
  module Models
    module Processing
      # Who can trigger this event?
      class StrategyStateActionPermission < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_state_action_permissions'
        belongs_to :strategy_role
        has_one :role, through: :strategy_role
        belongs_to :strategy_state_action
      end
    end
  end
end
