module Sipity
  module Controllers
    # Responsible for presenting a collection of actions
    class EnrichmentActionSetPresenter < Curly::Presenter
      presents :enrichment_action_set

      delegate :identifier, :entity, to: :enrichment_action_set

      # Naming it this way for Curly conventions
      def enrichment_actions
        @enrichment_action_set.collection
      end

      private

      attr_reader :enrichment_action_set
    end
  end
end
