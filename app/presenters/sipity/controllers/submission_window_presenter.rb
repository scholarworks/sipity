module Sipity
  module Controllers
    # Responsible for presenting a SubmissionWindow
    class SubmissionWindowPresenter < Curly::Presenter
      presents :submission_window

      delegate :work_area, :slug, to: :submission_window

      attr_reader :submission_window
      private :submission_window, :work_area

      def link
        link_to(slug, path)
      end

      def path
        submission_window_for_work_area_path(work_area_slug: work_area_slug, submission_window_slug: slug)
      end

      def work_area_slug
        work_area.slug
      end
    end
  end
end
