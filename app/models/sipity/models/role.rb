module Sipity
  module Models
    # A named concept that represents a set of responsibilities/verbs.
    # Often confused for a Group. Group represents people.
    # Roles represent what can/is done by anything/anyone having the given role.
    class Role < ActiveRecord::Base
      self.table_name = 'sipity_roles'

      has_many :processing_strategy_roles,
        dependent: :destroy,
        class_name: 'Sipity::Models::Processing::StrategyRole'
    end
  end
end
