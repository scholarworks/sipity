require 'spec_helper'

module Sipity
  module Forms
    module Etd
      RSpec.describe SubmitForReviewForm do
        let(:processing_entity) { Models::Processing::Entity.new(strategy_id: 1) }
        let(:work) { double('Work', to_processing_entity: processing_entity) }
        let(:repository) { CommandRepositoryInterface.new }
        let(:action) { Models::Processing::StrategyAction.new(strategy_id: processing_entity.strategy_id) }
        let(:user) { User.new(id: 1) }
        subject { described_class.new(work: work, processing_action_name: action) }

        context 'processing_action_name to action conversion' do
          it 'will use the given action if the strategy matches' do
            subject = described_class.new(work: work, processing_action_name: action)
            expect(subject.action).to eq(action)
          end

          it 'will attempt to find the action based on name and strategy' do
            expect(Models::Processing::StrategyAction).to receive(:find_by).
              with(name: 'submit_for_review', strategy_id: processing_entity.strategy_id).
              and_return(action)
            subject = described_class.new(work: work, processing_action_name: 'submit_for_review')
            expect(subject.action).to eq(action)
          end

          it 'will choke if the name is not found' do
            expect(Models::Processing::StrategyAction).to receive(:find_by).
              with(name: 'submit_for_review', strategy_id: processing_entity.strategy_id).
              and_return(nil)
            expect { described_class.new(work: work, processing_action_name: 'submit_for_review') }.
              to raise_error(Exceptions::ProcessingStrategyActionConversionError)
          end
        end

        it 'will log the event' do
          expect(repository).to receive(:log_event!).and_call_original
          subject.submit(repository: repository, requested_by: user)
        end

        it 'will register than the given action was taken on the entity' do
          expect(repository).to receive(:register_action_taken_on_entity).and_call_original
          subject.submit(repository: repository, requested_by: user)
        end

        it 'will update the processing state' do
          strategy_state = action.build_resulting_strategy_state
          expect(repository).to receive(:update_processing_state!).
            with(entity: work, to: strategy_state).and_call_original
          subject.submit(repository: repository, requested_by: user)
        end

        it 'will send differing notifications to the creating user, etd reviewer, and advisor' do
          expect(repository).to receive(:send_notification_for_entity_trigger).
            with(notification: 'confirmation_of_entity_submitted_for_review', entity: work, acting_as: 'creating_user')
          expect(repository).to receive(:send_notification_for_entity_trigger).
            with(notification: 'entity_ready_for_review', entity: work, acting_as: ['etd_reviewer', 'advisor'])
          subject.submit(repository: repository, requested_by: user)
        end
      end
    end
  end
end
