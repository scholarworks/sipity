module Sipity
  module Controllers
    module SubmissionWindows
      # Responsible for rendering a resourceful action in the context of a
      # WorkArea.
      class ResourcefulActionPresenter < Sipity::Controllers::ResourcefulActionPresenter
        presents :submission_window

        attr_reader :submission_window
        private :submission_window

        delegate :slug, to: :submission_window, prefix: :submission_window
        delegate :work_area_slug, to: :submission_window

        def path
          submission_window_query_action_path(
            work_area_slug: work_area_slug, submission_window_slug: submission_window_slug, query_action_name: action_name
          )
        end
      end
    end
  end
end
