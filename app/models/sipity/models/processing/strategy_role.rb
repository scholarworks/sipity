module Sipity
  module Models
    module Processing
      class StrategyRole < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_roles'

        belongs_to :role, class_name: '::Sipity::Models::Role'
        belongs_to :strategy
        has_many :strategy_authorities, dependent: :destroy
        has_many :strategy_event_permissions, dependent: :destroy
      end
    end
  end
end
