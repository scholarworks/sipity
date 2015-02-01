module Sipity
  module Models
    module Processing
      # The intersection of an Actor and a Role. In other words, what are the
      # actor's responsibilities?
      class StrategyResponsibility < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_responsibilities'
        belongs_to :actor
        belongs_to :strategy_role
        has_many :entity_permissions, dependent: :destroy
      end
    end
  end
end
