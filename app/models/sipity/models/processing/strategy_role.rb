module Sipity
  module Models
    module Processing
      class StrategyRole < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_roles'

        belongs_to :role
        belongs_to :strategy
        has_many :strategy_authorities, dependent: :destroy
      end
    end
  end
end
