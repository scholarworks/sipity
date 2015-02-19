require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe EventTriggerQueries, type: :isolated_repository_module do
      let(:work) { Models::Work.new(id: 123, processing_state: 'new') }
      context '#build_event_trigger_form' do
        let(:valid_processing_action_name) { '__arbitrary__' }
        context 'with valid enrichment type (to demonstrate collaboration)' do
          subject { test_repository.build_event_trigger_form(work: work, processing_action_name: valid_processing_action_name) }
          it { should respond_to :work }
          it { should respond_to :submit }
          it { should respond_to :valid? }
        end
      end
    end
  end
end
