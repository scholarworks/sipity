module Sipity
  module DataGenerators
    # Responsible for creating a SubmissionWindow within a given WorkArea
    #
    # It will also attempt to reuse an existing
    # Sipity::Models::ProcessingStrategy
    class FindOrCreateSubmissionWindow
      def self.call(**keywords, &block)
        new(**keywords).call(&block)
      end

      def initialize(slug:, work_area:)
        self.slug = slug
        self.work_area = work_area
      end

      private

      attr_accessor :slug, :work_area
      attr_reader :submission_window, :work_area

      def work_area=(input)
        @work_area = PowerConverter.convert(input, to: :work_area)
      end

      public

      def call
        submission_window = create_submission_window!
        associate_submission_window_with_processing_strategy_usage(submission_window)
        yield(submission_window) if block_given?
      end

      private

      def create_submission_window!
        Models::SubmissionWindow.find_or_create_by!(work_area_id: work_area.id, slug: PowerConverter.convert_to_slug(slug))
      end

      def associate_submission_window_with_processing_strategy_usage(submission_window)
        return submission_window.strategy_usage if submission_window.strategy_usage.present?
        work_area_specific_submission_window_generator.call(work_area: work_area, submission_window: submission_window)
      end

      def work_area_specific_submission_window_generator
        "Sipity::DataGenerators::#{work_area.demodulized_class_prefix_name}::SubmissionWindowProcessingGenerator".constantize
      end
    end
  end
end
