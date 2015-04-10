require 'spec_helper'

module Sipity
  module Services
    RSpec.describe UpdateEntityProcessingState do
      let(:entity) { Models::Processing::Entity.new(id: 1, strategy_id: strategy.id, strategy: strategy) }
      let(:strategy) { Models::Processing::Strategy.new(id: 2) }

      subject { described_class.new(entity: entity, processing_state: processing_state) }

      context '.call' do
        it 'will instantiate then call the instance' do
          expect(described_class).to receive(:new).and_return(double(call: true))
          described_class.call(entity: entity, processing_state: 'submit_for_review')
        end
      end

      context 'with a processing state string' do
        before do
          Models::Processing::StrategyState.create!(strategy_id: strategy.id, name: 'submit_for_review')
        end
        let(:processing_state) { 'submit_for_review' }
        it 'will change the processing state' do
          expect(entity).to receive(:update!).with(strategy_state: kind_of(Models::Processing::StrategyState))
          subject.call
        end
      end

      context 'with a processing state object' do
        let(:processing_state) { Models::Processing::StrategyState.new(id: 2, strategy_id: strategy.id, name: 'submit_for_review') }
        before do
          allow(entity).to receive(:update!).with(strategy_state: kind_of(Models::Processing::StrategyState))
        end
        it 'will change the processing state' do
          expect(entity).to receive(:update!).with(strategy_state: kind_of(Models::Processing::StrategyState))
          subject.call
        end

        it 'will mark as stale all comments for the new processing state' do
          comment = Models::Processing::Comment.create!(
            entity_id: entity.id, actor_id: 99, comment: 'a comment', stale: false, originating_strategy_state_id: processing_state.id,
            originating_strategy_action_id: 2
          )
          subject.call
          expect(comment.reload.stale?).to be_truthy
        end
      end
    end
  end
end
