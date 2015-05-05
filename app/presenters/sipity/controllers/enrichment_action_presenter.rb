module Sipity
  module Controllers
    # Responsible for presenting an enrichment action
    class EnrichmentActionPresenter < Curly::Presenter
      presents :enrichment_action

      attr_reader :enrichment_action
      private :enrichment_action

      delegate :name, to: :enrichment_action, prefix: :action

      def initialize(context, options = {})
        self.repository = options.delete(:repository) { default_repository }
        super
      end

      private

      attr_accessor :repository

      def default_repository
        QueryRepository.new
      end

      # Needed to determine if the action has been completed
      def entity
        fail NotImplementedError
      end
    end
  end
end
