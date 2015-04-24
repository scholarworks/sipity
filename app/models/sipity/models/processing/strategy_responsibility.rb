module Sipity
  module Models
    module Processing
      # The intersection of an Actor and a Role. In other words, the actor
      # is paid to do things; What do those things represent.
      #
      # @see Sipity::Models::Role for discussion of roles
      class StrategyResponsibility < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_responsibilities'
        belongs_to :actor
        belongs_to :strategy_role
      end
    end
  end
end
