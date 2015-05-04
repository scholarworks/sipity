module Sipity
  module Controllers
    # Responsible for presenting a SubmissionWindow
    class SubmissionWindowPresenter < Curly::Presenter
      presents :submission_window

      def initialize(context, options = {})
        self.repository = options.delete(:repository) || default_repository
        # Because controller actions may not cooperate and instead set a
        # :view_object.
        options['submission_window'] ||= options['view_object']
        super
      end

      delegate :work_area, :work_area_slug, :slug, to: :submission_window

      attr_reader :submission_window
      private :submission_window, :work_area

      def link
        link_to(slug, path)
      end

      def path
        submission_window_for_work_area_path(work_area_slug: work_area_slug, submission_window_slug: slug)
      end

      private

      attr_accessor :repository

      def default_repository
        QueryRepository.new
      end
    end
  end
end
