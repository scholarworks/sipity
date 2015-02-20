require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe WorkEventTriggers do
      context '#find_event_trigger_form_builder' do
        [
          ['submit_for_review', Etd::SubmitForReviewForm],
          ['something_else', WorkEventTriggerForm]
        ].each_with_index do |(processing_action_name, form_class), index|
          it "will return #{form_class} for processing_action_name: #{processing_action_name} (Scenario ##{index}" do
            expect(described_class.find_event_trigger_form_builder(processing_action_name: processing_action_name)).
              to eq(form_class)
          end
        end
      end
    end
  end
end
