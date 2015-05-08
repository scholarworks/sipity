module Sipity
  module Runners
    # Responsible for being a collection of SubmissionWindow runners
    module SubmissionWindowRunners
      # :nodoc:
      class CommandQueryAction < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(work_area_slug:, submission_window_slug:, processing_action_name:, attributes: {})
          submission_window = repository.find_submission_window_by(slug: submission_window_slug, work_area: work_area_slug)
          form = repository.build_submission_window_processing_action_form(
            submission_window: submission_window, processing_action_name: processing_action_name, attributes: attributes
          )
          authorization_layer.enforce!(processing_action_name => form) do
            yield(form)
          end
        end
      end
      private_constant :CommandQueryAction

      # The general handler for general query actions (show may be a customized
      # case).
      class QueryAction < CommandQueryAction
        def run(**keywords)
          super do |form|
            callback(:success, form)
          end
        end
      end

      # The general handler for general query actions (show may be a customized
      # case).
      class CommandAction < CommandQueryAction
        def run(**keywords)
          super do |form|
            returned_object = form.submit(requested_by: current_user)
            if returned_object
              callback(:submit_success, returned_object)
            else
              callback(:submit_failure, form)
            end
          end
        end
      end
    end
  end
end
