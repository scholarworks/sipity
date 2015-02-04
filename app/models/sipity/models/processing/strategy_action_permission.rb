module Sipity
  module Models
    module Processing
      # Who can trigger this event?
      class StrategyEventPermission < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_event_permissions'
        belongs_to :strategy_role
        belongs_to :strategy_event
      end
    end
  end
end
