require 'spec_helper'

module Sipity
  module Commands
    RSpec.describe TodoListCommands, type: :isolated_repository_module do
      let(:work) { Models::Work.new(id: 1, work_type: 'etd', processing_state: 'new') }
      let(:user) { double }

      context '#register_action_taken_on_entity' do
        let(:existing_enrichment_type) { 'describe' }
        it "will call the underlying service object" do
          expect(Services::RegisterActionTakenOnEntity).to receive(:call)
          test_repository.register_action_taken_on_entity(work: work, enrichment_type: existing_enrichment_type, requested_by: user)
        end
      end
    end
  end
end
