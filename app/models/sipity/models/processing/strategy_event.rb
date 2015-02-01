module Sipity
  module Models
    module Processing
      class StrategyEvent < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_events'
        belongs_to :originating_strategy_state, class_name: 'StrategyState'
        belongs_to :resulting_strategy_state, class_name: 'StrategyState'
        belongs_to :strategy_action
        has_many :strategy_event_permissions, dependent: :destroy
        has_many :entity_event_registers, dependent: :destroy
      end
    end
  end
end
