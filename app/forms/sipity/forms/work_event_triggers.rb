# Because of the `const_defined?` I'm requiring the various sipity work
# enrichment forms.
module Sipity
  module Forms
    # A container for the various WorkEnrichment forms
    module WorkEventTriggers
      module_function

      def find_event_trigger_form_builder(event_name:)
        WorkEventTriggerForm
      end
    end
  end
end
