require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe EnrichmentQueries, type: :repository_methods do
      context '#build_enrichment_form' do
        let(:work) { double }
        let(:valid_enrichment_type) { 'attach' }
        context 'with valid enrichment type (to demonstrate collaboration)' do
          subject { test_repository.build_enrichment_form(work: work, enrichment_type: valid_enrichment_type) }
          it { should respond_to :work }
          it { should respond_to :submit }
          it { should respond_to :valid? }
        end
      end

      context '#todo_list_for_current_processing_state_of_work' do
        let(:work) { Models::Work.new(id: 123, processing_state: 'new') }
        let(:todo_attributes) { { entity: work, entity_processing_state: work.processing_state  } }
        let(:todo_item_1) { Models::TodoItemState.new(todo_attributes.merge(enrichment_type: 'describe', enrichment_state: 'incomplete')) }
        let(:todo_item_2) { Models::TodoItemState.new(todo_attributes.merge(enrichment_type: 'attach', enrichment_state: 'done')) }
        before do
          expect(Models::TodoItemState).to receive(:where).and_return([todo_item_1, todo_item_2])
        end

        subject { test_repository.todo_list_for_current_processing_state_of_work(work: work) }

        it 'will have elements in the "required" set' do
          # REVIEW: This is a lot of knowledge about the structure; But I'll let it stand.
          expect(subject.sets.fetch('required').map(&:name)).to eq([todo_item_1.enrichment_type, todo_item_2.enrichment_type])
        end
      end

      context '#are_all_of_the_required_todo_items_done_for_work?' do
        before do
          [
            ['etd', 'new', 'describe', 'required'],
            ['etd', 'new', 'attach', 'required'],
            ['etd', 'new', 'mogrify', 'optional'],
            ['etd', 'next', 'attach', 'required'],
            ['etd', 'next', 'another', 'required']
          ].each do |work_type, processing_state, enrichment_type, enrichment_group|
            Sipity::Models::WorkTypeTodoListConfig.create!(
              work_type: work_type,
              work_processing_state: processing_state,
              enrichment_type: enrichment_type,
              enrichment_group: enrichment_group
            )
          end
        end
        let(:work) { Models::Work.new(id: 123, processing_state: 'new', work_type: 'etd') }
        let(:persist_todo_item_state) do
          lambda do |options|
            work = options.fetch(:work)
            entity_type = Conversions::ConvertToPolymorphicType.call(work)
            processing_state = options.fetch(:processing_state) { work.processing_state }
            enrichment_type = options.fetch(:enrichment_type)
            enrichment_state = options.fetch(:enrichment_state)
            Models::TodoItemState.create!(
              entity_id: work.id, entity_type: entity_type,
              entity_processing_state: processing_state, enrichment_type: enrichment_type, enrichment_state: enrichment_state
            )
          end
        end

        it 'will return true if all required todo items are "done"' do
          persist_todo_item_state.call(work: work, enrichment_type: 'describe', enrichment_state: 'done')
          persist_todo_item_state.call(work: work, enrichment_type: 'attach', enrichment_state: 'done')
          expect(test_repository.are_all_of_the_required_todo_items_done_for_work?(work: work)).to eq(true)
        end

        it 'will return false if any required todo items are not "done"' do
          persist_todo_item_state.call(work: work, enrichment_type: 'describe', enrichment_state: 'done')
          persist_todo_item_state.call(work: work, enrichment_type: 'attach', enrichment_state: 'incomplete')
          expect(test_repository.are_all_of_the_required_todo_items_done_for_work?(work: work)).to eq(false)
        end

        it 'will return false if there are missing todo items that are required' do
          persist_todo_item_state.call(work: work, enrichment_type: 'describe', enrichment_state: 'done')
          expect(test_repository.are_all_of_the_required_todo_items_done_for_work?(work: work)).to eq(false)
        end

        it 'will return false if I have additional done todo items that but not all required are done' do
          persist_todo_item_state.call(work: work, enrichment_type: 'describe', enrichment_state: 'done')
          persist_todo_item_state.call(work: work, enrichment_type: 'mogrify', enrichment_state: 'done')
          expect(test_repository.are_all_of_the_required_todo_items_done_for_work?(work: work)).to eq(false)
        end
      end
    end
  end
end
