require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe EnrichmentQueries, type: :isolated_repository_module do
      let(:work) { Models::Work.new(id: 123, processing_state: 'new') }
      let(:todo_list_configurator) do
        lambda do
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
      end
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

      context '#build_enrichment_form' do
        let(:valid_enrichment_type) { 'attach' }
        context 'with valid enrichment type (to demonstrate collaboration)' do
          subject { test_repository.build_enrichment_form(work: work, enrichment_type: valid_enrichment_type) }
          it { should respond_to :work }
          it { should respond_to :submit }
          it { should respond_to :valid? }
        end
      end
    end
  end
end
