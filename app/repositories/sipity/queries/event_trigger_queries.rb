require 'sipity/forms/work_event_triggers'

module Sipity
  module Queries
    # Queries
    module EventTriggerQueries
      def build_event_trigger_form(attributes = {})
        event_name = attributes.fetch(:event_name)
        builder = Forms::WorkEventTriggers.find_event_trigger_form_builder(event_name: event_name)
        builder.new(attributes)
      end
    end
  end
end
