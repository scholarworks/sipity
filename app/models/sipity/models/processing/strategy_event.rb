module Sipity
  module Models
    module Processing
      class StrategyEvent < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_events'
      end
    end
  end
end
