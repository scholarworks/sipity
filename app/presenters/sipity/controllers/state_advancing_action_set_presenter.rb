module Sipity
  module Controllers
    # Responsible for presenting an enrichment action
    class StateAdvancingActionSetPresenter < Curly::Presenter
      presents :state_advancing_action_set

      delegate :entity, to: :state_advancing_action_set

      # Naming it this way for Curly conventions
      def enrichment_actions
        state_advancing_action_set.collection
      end

      private

      attr_reader :state_advancing_action_set
    end
  end
end
