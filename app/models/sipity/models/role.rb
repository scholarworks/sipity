module Sipity
  module Models
    class Role < ActiveRecord::Base
      self.table_name = 'sipity_roles'

      has_many :processing_strategy_roles, dependent: :destroy,
        class_name: 'Sipity::Models::Processing::StrategyRole'
    end
  end
end
