module Sipity
  module ResponseHandlers
    # This is an Experimental module and concept
    module SubmissionWindowHandler
      # Responsible for handling a :success-ful action
      class SuccessResponse < ResponseHandlers::WorkAreaHandler::SuccessResponse
      end

      # Forms that are submitted have a different success handling.
      class SubmitSuccessResponse < SuccessResponse
        # TODO: Need to Guard these methods
        delegate :redirect_to, :work_submission_path, :submission_window_path, to: :context
        delegate :object, to: :handled_response, prefix: :response

        def respond
          case response_object
          when Models::SubmissionWindow
            respond_for_submission_window
          when Models::Work
            redirect_to work_submission_path(work_id: response_object.id)
          else
            # Fallback to converting to a submission window.
            submission_window = PowerConverter.convert(response_object, to: :submission_window)
            respond_for_submission_window(submission_window: submission_window)
          end
        end

        private

        def respond_for_submission_window(submission_window: response_object)
          redirect_to(
            submission_window_path(work_area_slug: submission_window.work_area_slug, submission_window_slug: submission_window.slug)
          )
        end
      end

      # Forms that fail to submit may have different errors.
      class SubmitFailureResponse < SuccessResponse
      end
    end
  end
end
