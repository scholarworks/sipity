require 'power_converter'

module Sipity
  module ResponseHandlers
    # This is an Experimental module and concept
    #
    # @todo should this module be moved into the Runner's namespace? It would give a closer proximity to the code that was being leveraged.
    module SubmissionWindowHandler
      # Success! Huzzah
      module SuccessResponder
        def self.for_controller(handler:)
          handler.render(template: handler.template)
        end

        def self.for_command_line(*)
          true
        end
      end

      # We have a successful form submission.
      module SubmitSuccessResponder
        def self.for_controller(handler:)
          handler.redirect_to(PowerConverter.convert(handler.response_object, to: :access_path))
        end

        def self.for_command_line(*)
          true
        end
      end

      # Forms that raise to submit may have different errors.
      module SubmitFailureResponder
        def self.for_controller(handler:)
          handler.render(template: handler.template, status: :unprocessable_entity)
        end

        def self.for_command_line(handler:)
          raise(
            Sipity::Exceptions::ResponseHandlerError,
            object: handler.response_object,
            errors: handler.response_errors,
            status: handler.response_status
          )
        end
      end
    end
  end
end
