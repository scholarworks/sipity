module Sipity
  module ResponseHandlers
    # This is an Experimental module and concept
    module SubmissionWindowHandler
      # Success! Huzzah
      module SuccessResponder
        def self.call(handler:)
          handler.render(template: handler.template)
        end
      end

      # We have a successful form submission.
      module SubmitSuccessResponder
        module_function

        def call(handler:)
          case handler.response_object
          when Models::SubmissionWindow
            respond_for_submission_window(handler: handler, submission_window: handler.response_object)
          when Models::Work
            # Violating the Law of Demeter-------------------------------------------V
            handler.redirect_to handler.work_submission_path(work_id: handler.response_object.id)
          else
            # Fallback to converting to a submission window.
            submission_window = PowerConverter.convert(handler.response_object, to: :submission_window)
            respond_for_submission_window(handler: handler, submission_window: submission_window)
          end
        end

        def respond_for_submission_window(handler:, submission_window:)
          handler.redirect_to(
            handler.submission_window_path(work_area_slug: submission_window.work_area_slug, submission_window_slug: submission_window.slug)
          )
        end
      end

      # Forms that fail to submit may have different errors.
      module SubmitFailureResponder
        def self.call(handler:)
          handler.render(template: handler.template, status: :unprocessable_entity)
        end
      end
    end
  end
end
