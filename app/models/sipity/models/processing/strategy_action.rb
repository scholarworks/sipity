module Sipity
  module Models
    module Processing
      # When an actor attempts to take an action what is the originating state
      # and what is the resulting state?
      class StrategyAction < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_actions'
        belongs_to :originating_strategy_state, class_name: 'StrategyState'
        belongs_to :strategy_event
        has_many :strategy_action_permissions, dependent: :destroy
      end
    end
  end
end
