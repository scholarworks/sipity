module Sipity
  module Forms
    # A container for the various WorkEnrichment forms
    module WorkEventTriggers
      module_function

      def find_event_trigger_form_builder(options = {})
        # TODO: We are storing the form to use in the action; Leverage that.
        # However, to get things moving this will be an adequate short-cut
        processing_action_name = options.fetch(:processing_action_name)
        "Sipity::Forms::Etd::#{processing_action_name.classify}Form".constantize
      rescue NameError
        WorkEventTriggerForm
      end
    end
  end
end
