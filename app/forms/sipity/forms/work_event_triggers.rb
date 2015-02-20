module Sipity
  module Forms
    # A container for the various WorkEnrichment forms
    module WorkEventTriggers
      module_function

      def find_event_trigger_form_builder(options = {})
        # TODO: We are storing the form to use in the action; Leverage that.
        # However, to get things moving this will be an adequate short-cut
        case options.fetch(:processing_action_name)
        when 'submit_for_review' then Etd::SubmitForReviewForm
        else
          WorkEventTriggerForm
        end
      end
    end
  end
end
