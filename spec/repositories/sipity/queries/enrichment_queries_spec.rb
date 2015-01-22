require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe EnrichmentQueries, type: :repository_methods do
      context '#build_enrichment_form' do
        let(:work) { double }
        let(:valid_enrichment_type) { 'attach' }
        let(:invalid_enrichment_type) { '__very_much_not_valid__' }
        context 'with valid enrichment type' do
          subject { test_repository.build_enrichment_form(work: work, enrichment_type: valid_enrichment_type) }
          it { should respond_to :work }
          it { should respond_to :submit }
          it { should respond_to :valid? }
        end
        context 'with invalid enrichment type' do
          it 'will raise an exception' do
            expect { test_repository.build_enrichment_form(work: work, enrichment_type: invalid_enrichment_type) }.
              to raise_error(Exceptions::EnrichmentNotFoundError)
          end
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
    end
  end
end
