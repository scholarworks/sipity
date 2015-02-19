require 'spec_helper'

module Sipity
  module Commands
    RSpec.describe TodoListCommands, type: :isolated_repository_module do
      let(:work) { Models::Work.new(id: 1, work_type: 'etd', processing_state: 'new') }

      context '#mark_work_todo_item_as_done' do
        let(:existing_enrichment_type) { 'describe' }
        it "will call the underlying service object" do
          expect(Services::RegisterActionTakenOnEntity).to receive(:call)
          test_repository.mark_work_todo_item_as_done(work: work, enrichment_type: existing_enrichment_type)
        end
      end
    end
  end
end
