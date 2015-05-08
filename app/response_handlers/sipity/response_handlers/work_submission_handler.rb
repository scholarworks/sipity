module Sipity
  module ResponseHandlers
    # This is an Experimental module and concept
    module WorkSubmissionHandler
      # It worked
      module SuccessResponder
        def self.call(handler:)
          handler.render(template: handler.template)
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
