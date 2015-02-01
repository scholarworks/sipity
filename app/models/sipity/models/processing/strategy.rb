module Sipity
  module Models
    module Processing
      class Strategy < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategies'

        has_many :entities, dependent: :destroy
        has_many :strategy_states, dependent: :destroy
        has_many :strategy_actions, dependent: :destroy
        has_many :strategy_roles, dependent: :destroy
        has_many :roles, through: :strategy_roles
      end
    end
  end
end
