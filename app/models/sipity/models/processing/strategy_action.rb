module Sipity
  module Models
    module Processing
      # A named action that, during the processing of an entity, may be taken.
      class StrategyAction < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_actions'
        belongs_to :strategy
        has_many :strategy_events, dependent: :destroy
      end
    end
  end
end
