module Sipity
  module ResponseHandlers
    # This is an Experimental module and concept
    #
    # @todo should this module be moved into the Runner's namespace? It would give a closer proximity to the code that was being leveraged.
    module WorkAreaHandler
      # Huzzah! Success
      module SuccessResponder
        def self.call(handler:)
          handler.render(template: handler.template)
        end
      end

      # Forms that raise to submit may have different errors.
      module SubmitFailureResponder
        def self.call(handler:)
          handler.render(template: handler.template, status: :unprocessable_entity)
        end
      end
    end
  end
end
