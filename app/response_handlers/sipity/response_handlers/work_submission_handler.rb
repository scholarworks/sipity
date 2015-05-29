module Sipity
  module ResponseHandlers
    # These handlers are very nosy; In object perlance they are doing little on
    # their own, but instead coordinating that reality.
    module WorkSubmissionHandler
      # It worked
      module SuccessResponder
        def self.call(handler:)
          handler.render(template: handler.template)
        end
      end

      # We have a successful form submission.
      module SubmitSuccessResponder
        def self.call(handler:)
          # Do I need to include the response_object
          handler.redirect_to(handler.work_submission_path(work_id: handler.response_object.id))
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
