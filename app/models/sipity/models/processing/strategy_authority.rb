module Sipity
  module Models
    module Processing
      class StrategyAuthority < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_authorities'
        belongs_to :actor
        belongs_to :strategy_role
        has_many :entity_permissions, dependent: :destroy
      end
    end
  end
end
