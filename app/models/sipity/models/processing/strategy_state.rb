module Sipity
  module Models
    module Processing
      class StrategyState < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_states'
      end
    end
  end
end
