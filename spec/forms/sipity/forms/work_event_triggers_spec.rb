require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe WorkEventTriggers do
      context '#find_event_trigger_form_builder' do
        let(:valid_event_name) { 'submit_for_review' }
        context 'with valid event name' do
          subject { described_class.find_event_trigger_form_builder(event_name: valid_event_name) }
          it { should respond_to(:new) }
        end
      end
    end
  end
end
