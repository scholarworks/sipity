require 'power_converter'

module Sipity
  module ResponseHandlers
    # These handlers are very nosy; In object perlance they are doing little on
    # their own, but instead coordinating that reality.
    module WorkSubmissionHandler
      # Unauthenticated so do nothing
      module UnauthenticatedResponder
        def self.call(*)
          nil
        end
      end

      # It worked
      module SuccessResponder
        def self.call(handler:)
          handler.render(template: handler.template)
        end
      end

      # We have a successful form submission.
      module SubmitSuccessResponder
        def self.call(handler:)
          handler.redirect_to(PowerConverter.convert_to_access_path(handler.response_object))
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
