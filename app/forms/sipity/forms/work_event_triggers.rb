module Sipity
  module Forms
    # A container for the various WorkEnrichment forms
    module WorkEventTriggers
      module_function

      def find_event_trigger_form_builder(_options = {})
        WorkEventTriggerForm
      end
    end
  end
end
