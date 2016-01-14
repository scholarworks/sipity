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

      def initialize(slug:, work_area:, **submission_window_attributes)
        self.slug = slug
        self.work_area = work_area
        self.submission_window_attributes = submission_window_attributes.
          slice(:open_for_starting_submissions_at, :closed_for_starting_submissions_at).stringify_keys
      end

      private

      attr_accessor :slug, :submission_window_attributes
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
        return window if window.attributes.slice(*submission_window_attributes.keys) == submission_window_attributes
        window.update_attributes(submission_window_attributes)
        window
      end

      def build_submission_window_workflow!
        work_area_specific_submission_window_generator.call(work_area: work_area, submission_window: submission_window)
        WorkTypeGenerator.generate_from_json_file(submission_window: submission_window, path: path_to_work_type_configuration)
      end

      def work_area_specific_submission_window_generator
        "Sipity::DataGenerators::SubmissionWindows::#{work_area.demodulized_class_prefix_name}Generator".constantize
      end

      def path_to_work_type_configuration
        Rails.root.join('app/data_generators/sipity/data_generators/work_types/', "#{work_area.partial_suffix}_work_types.json")
      end
    end
  end
end
