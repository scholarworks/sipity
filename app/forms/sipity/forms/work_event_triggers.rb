module Sipity
  module Forms
    # A container for the various WorkEnrichment forms
    module WorkEventTriggers
      module_function

      def find_event_trigger_form_builder(options = {})
        # TODO: We are storing the form to use in the action; Leverage that.
        # However, to get things moving this will be an adequate short-cut
        processing_action_name = options.fetch(:processing_action_name)
        form_name_by_convention = "#{processing_action_name.classify}Form"
        container = "Sipity::Forms::Etd"
        "#{container}::#{form_name_by_convention}".constantize
      rescue NameError
        raise Exceptions::EventTriggerFormNotFoundError, name: form_name_by_convention, container: container
      end
    end
  end
end
