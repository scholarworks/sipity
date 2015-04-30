module Sipity
  module Runners
    module WorkAreaRunners
      # Responsible for responding with a work area
      class Show < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default
        self.action_name = :show?

        def run(work_area_slug:)
          work_area = repository.find_work_area_by(slug: work_area_slug)
          authorization_layer.enforce!(action_name => work_area) do
            callback(:success, work_area)
          end
        end
      end

      # Responsible for responding with a submission window
      class SubmissionWindow < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default
        self.action_name = :show?

        def run(work_area_slug:, submission_window_slug:)
          submission_window = repository.find_submission_window_by(slug: submission_window_slug, work_area: work_area_slug)
          authorization_layer.enforce!(action_name => submission_window) do
            callback(:success, submission_window)
          end
        end
      end
    end
  end
end
