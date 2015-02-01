module Sipity
  module Models
    module Processing
      class StrategyState < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_states'
        belongs_to :strategy
        has_many :strategy_events, dependent: :destroy
      end
    end
  end
end
