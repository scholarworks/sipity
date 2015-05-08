module Sipity
  module ResponseHandlers
    # This is an Experimental module and concept
    module WorkAreaHandler
      # Huzzah! Success
      module SuccessResponder
        def self.call(handler:)
          handler.render(template: handler.template)
        end
      end
    end
  end
end
