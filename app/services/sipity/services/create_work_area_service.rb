module Sipity
  module Services
    # Codifies what it takes to "bootstrap" a bare-bones work area.
    class CreateWorkAreaService
      def self.call(**keywords)
        new(**keywords).call
      end

      def initialize(slug:, **keywords)
        partial_suffix = keywords.fetch(:partial_suffix, slug)
        demodulized_class_prefix_name = keywords.fetch(:demodulized_class_prefix_name, slug)
        self.work_area = Models::WorkArea.new(
          slug: slug, partial_suffix: partial_suffix, demodulized_class_prefix_name: demodulized_class_prefix_name
        )
      end

      def call
        create_work_area!
        create_processing_strategy!
        create_work_area_processing_entity!
        work_area
      end

      private

      delegate :slug, to: :work_area

      def create_work_area!
        work_area.save! unless work_area.persisted?
      end

      def create_processing_strategy!
        @processing_strategy ||= Models::Processing::Strategy.create!(proxy_for: work_area, name: "#{slug} processing strategy")
      end

      def create_work_area_processing_entity!
        work_area.create_processing_entity!(strategy: processing_strategy, strategy_state: processing_strategy.initial_strategy_state)
      end

      attr_accessor :work_area
      attr_reader :processing_strategy
    end
  end
end
