require 'spec_helper'

module Sipity
  module Queries
    RSpec.describe EventTriggerQueries, type: :isolated_repository_module  do
      context '#build_event_trigger_form' do
        let(:attributes) { { processing_action_name: 'hello', work: Models::Work.new, chicken: 'soup' } }
        let(:builder) { double('Builder', new: true) }
        it 'will find the correct form and initialize it' do
          expect(Forms::WorkEventTriggers).to receive(:find_event_trigger_form_builder).
            and_return(builder)
          test_repository.build_event_trigger_form(attributes)
          expect(builder).to have_received(:new).with(attributes.merge(repository: test_repository))
        end
      end
    end
  end
end
