require 'sipity/forms/work_event_triggers'

module Sipity
  module Queries
    # Queries
    module EventTriggerQueries
      def build_event_trigger_form(attributes = {})
        processing_action_name = attributes.fetch(:processing_action_name)
        builder = Forms::WorkEventTriggers.find_event_trigger_form_builder(processing_action_name: processing_action_name)
        builder.new(attributes)
      end
    end
  end
end
