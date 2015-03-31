module Sipity
  module Models
    module Processing
      # Within the Sipity system it is necessary to consider some actions as
      # analogous to other actions.
      #
      # @example
      #   Consider the "Advisor Signoff" action of our ETD system. It requires
      #   multiple signoffs from different people before the state finally
      #   changes.
      #
      #   If I am an advisor and I signoff on the ETD, I don't want to see
      #   the button for "Advisor Signoff" again. Related to that, I don't want
      #   to see the "Request Changes" button.
      #
      #   In this example, the "Request Changes" would be an analogue of the
      #   "Advisor Signoff" in regards to disallowing/hiding the button if the
      #   action is already taken.
      #
      # @note This is indicative of a modeling issue; That is to say there are
      #   several questions/rules that could be pushed into the database and
      #   enforced via SQL (once the normalized shape is understood).
      #
      #   For example, the concept of an action could have the following
      #   property:
      #   * permitted_to_repeat_action_withing_a_given_state
      class StrategyActionAnalogue < ActiveRecord::Base
        self.table_name = 'sipity_processing_strategy_action_analogues'
        belongs_to :strategy_action
        belongs_to :analogous_to_strategy_action, class_name: 'Sipity::Models::Processing::StrategyAction'

        validate :strategy_action_and_analog_cannot_be_the_same

        private

        # I'd prefer this to be a database constraint but that does not appear
        # to be possible.
        def strategy_action_and_analog_cannot_be_the_same
          errors.add(:strategy_action_id) if strategy_action == analogous_to_strategy_action
        end
      end
    end
  end
end
