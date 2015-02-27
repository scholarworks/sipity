require 'sipity/forms/work_event_triggers'

module Sipity
  module Queries
    # Queries
    module EventTriggerQueries
      def build_event_trigger_form(attributes = {})
        builder = Forms::WorkEventTriggers.find_event_trigger_form_builder(attributes.slice(:processing_action_name, :work))
        builder.new(attributes.merge(repository: self))
      end
    end
  end
end
