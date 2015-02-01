module Sipity
  module Models
    module Processing
      class StrategyAction < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_actions'
        belongs_to :strategy
        has_many :strategy_events, dependent: :destroy
      end
    end
  end
end
