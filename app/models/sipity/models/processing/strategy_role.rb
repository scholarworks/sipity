module Sipity
  module Models
    module Processing
      # For a given processing strategy, what roles have a part to play in
      # the processing?
      class StrategyRole < ActiveRecord::Base
        ENTITY_LEVEL_RESPONSIBILITY = 'entity_level'.freeze
        STRATEGY_LEVEL_RESPONSIBILITY = 'strategy_level'.freeze

        self.table_name = 'sipity_processing_strategy_roles'

        belongs_to :role, class_name: '::Sipity::Models::Role'
        belongs_to :strategy
        has_many :strategy_responsibilities, dependent: :destroy
        has_many :strategy_state_action_permissions, dependent: :destroy
        has_many :entity_specific_responsibilities, dependent: :destroy
      end
    end
  end
end
