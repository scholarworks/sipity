module Sipity
  module Controllers
    module WorkSubmissions
      # Responsible for rendering a resourceful action in the context of a
      # WorkArea.
      class ResourcefulActionPresenter < Sipity::Controllers::ResourcefulActionPresenter
        presents :work_submission

        attr_reader :work_submission
        private :work_submission

        def path
          work_submission_action_path(work_id: work_submission.id, processing_action_name: action_name)
        end
      end
    end
  end
end
