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

      def initialize(slug:, work_area:, open_for_starting_submissions_at: nil, closed_for_starting_submissions_at: nil)
        self.slug = slug
        self.work_area = work_area
        self.open_for_starting_submissions_at = open_for_starting_submissions_at
        self.closed_for_starting_submissions_at = closed_for_starting_submissions_at
      end

      private

      attr_accessor :slug, :open_for_starting_submissions_at, :closed_for_starting_submissions_at
      attr_reader :submission_window, :work_area

      def work_area=(input)
        @work_area = PowerConverter.convert(input, to: :work_area)
      end

      public

      def call
        @submission_window = create_submission_window!
        build_submission_window_workflow!
        yield(submission_window) if block_given?
        submission_window
      end

      private

      def create_submission_window!
        window = Models::SubmissionWindow.find_or_create_by!(work_area_id: work_area.id, slug: PowerConverter.convert_to_slug(slug))
        return window if window.open_for_starting_submissions_at == open_for_starting_submissions_at &&
          window.closed_for_starting_submissions_at == closed_for_starting_submissions_at
        window.update_attributes(
          open_for_starting_submissions_at: open_for_starting_submissions_at,
          closed_for_starting_submissions_at: closed_for_starting_submissions_at
        )
        window
      end

      def build_submission_window_workflow!
        work_area_specific_submission_window_generator.call(work_area: work_area, submission_window: submission_window)
        work_area_specific_work_types_generator.call(work_area: work_area, submission_window: submission_window)
      end

      def work_area_specific_submission_window_generator
        "Sipity::DataGenerators::SubmissionWindows::#{work_area.demodulized_class_prefix_name}Generator".constantize
      end

      def work_area_specific_work_types_generator
        "Sipity::DataGenerators::WorkTypes::#{work_area.demodulized_class_prefix_name}Generator".constantize
      end
    end
  end
end
