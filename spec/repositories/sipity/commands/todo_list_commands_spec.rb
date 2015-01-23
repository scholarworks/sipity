require 'spec_helper'

module Sipity
  module Commands
    RSpec.describe TodoListCommands, type: :repository_methods do
      let(:work) { Models::Work.new(id: 1, work_type: 'etd', processing_state: 'new') }

      context '#create_work_todo_list_for_current_state' do
        it 'will persist TodoItemState items' do
          expect { test_repository.create_work_todo_list_for_current_state(work: work) }.
            to change { Models::TodoItemState.count }
        end

        # This is included as a reminder that Rails is always looking to persist
        # things, even though I don't need it persisted. This is, however,
        # calling attention to the fact that maybe I should be looking towards
        # fixtures.
        it 'will not persist an unpersisted work (because of Rails magic)' do
          expect { test_repository.create_work_todo_list_for_current_state(work: work) }.
            to_not change { work.persisted? }
        end
      end

      context '#mark_work_todo_item_as_done' do
        let(:existing_enrichment_type) { 'describe' }
        let(:done_state) { Models::TodoItemState::ENRICHMENT_STATE_DONE }
        it "will find an existing todo item then transition its state to 'done'" do
          todo_item = test_repository.send(
            :create_named_entity_todo_item_for_current_state,
            entity: work, entity_processing_state: work.processing_state, enrichment_type: existing_enrichment_type
          )
          expect(todo_item.enrichment_state).to_not eq(done_state)

          test_repository.mark_work_todo_item_as_done(work: work, enrichment_type: existing_enrichment_type)

          expect(todo_item.reload.enrichment_state).to eq(done_state)
        end

        it 'will create a new "done" todo item if a matching todo item does not exist because we should acknowledge their achievement' do
          expect { test_repository.mark_work_todo_item_as_done(work: work, enrichment_type: existing_enrichment_type) }.
            to change { Models::TodoItemState.count }.by(1)
        end
      end
    end
  end
end
