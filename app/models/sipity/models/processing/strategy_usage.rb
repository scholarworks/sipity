module Sipity
  module Models
    module Processing
      # Responsible for defining how a strategy is used.
      #
      # This takes a code-based assumption and crafts it into something more
      # dynamic.
      class StrategyUsage < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_usages'
        belongs_to :stragegy
        belongs_to :usage, polymorphic: true
      end
    end
  end
end
