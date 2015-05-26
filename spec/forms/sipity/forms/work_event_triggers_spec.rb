require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe WorkEventTriggers do
      context '#find_event_trigger_form_builder' do
        it 'will raise an exception if no trigger can be inferred' do
          expect { described_class.find_event_trigger_form_builder(processing_action_name: 'bilbo_baggins') }.
            to raise_error(Exceptions::EventTriggerFormNotFoundError)
        end
      end
    end
  end
end
