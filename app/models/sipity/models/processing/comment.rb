module Sipity
  module Models
    module Processing
      # Responsible for capturing a :comment made by a given :actor on a given
      # :entity at a given :originating_strategy_state as part of a given
      # :originating_strategy_action.
      #
      # A :stale comment is a comment that is not relevant based on processing
      # that has happened.
      #
      # @example
      #   As a graduate student that has had multiple changes requested by an advisor
      #   I want to see my advisors latest comments (and not previous comments from a previous requested change)
      #   So that I can see the immediate thing I need to work on
      class Comment < ActiveRecord::Base
        self.table_name = 'sipity_processing_comments'

        belongs_to :actor, class_name: 'Sipity::Models::Processing::Actor'
        belongs_to :entity, class_name: 'Sipity::Models::Processing::Entity'
        belongs_to :originating_strategy_action, class_name: 'Sipity::Models::Processing::StrategyAction'
        belongs_to :originating_strategy_state, class_name: 'Sipity::Models::Processing::StrategyState'
      end
    end
  end
end
