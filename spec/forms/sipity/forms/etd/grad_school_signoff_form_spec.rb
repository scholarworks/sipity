require 'spec_helper'

module Sipity
  module Forms
    module Etd
      RSpec.describe GradSchoolSignoffForm do
        let(:processing_entity) { Models::Processing::Entity.new(strategy_id: 1) }
        let(:work) { double('Work', to_processing_entity: processing_entity) }
        let(:repository) { CommandRepositoryInterface.new }
        let(:action) { Models::Processing::StrategyAction.new(strategy_id: processing_entity.strategy_id, name: "hello") }
        let(:user) { User.new(id: 1) }
        subject { described_class.new(work: work, processing_action_name: action, repository: repository) }

        its(:processing_action_name) { should eq(action.name) }

        context 'processing_action_name to action conversion' do
          it 'will use the given action if the strategy matches' do
            subject = described_class.new(work: work, processing_action_name: action, repository: repository)
            expect(subject.action).to eq(action)
          end
        end

        it 'will log the event' do
          expect(repository).to receive(:log_event!).and_call_original
          subject.submit(requested_by: user)
        end

        it 'will register than the given action was taken on the entity' do
          expect(repository).to receive(:register_action_taken_on_entity).and_call_original
          subject.submit(requested_by: user)
        end

        it 'will update the processing state' do
          strategy_state = action.build_resulting_strategy_state
          expect(repository).to receive(:update_processing_state!).
            with(entity: work, to: strategy_state).and_call_original
          subject.submit(requested_by: user)
        end

        it 'will send notifications to the creating user, etd reviewer, and advisor' do
          expect(repository).to receive(:send_notification_for_entity_trigger).
            with(notification: 'confirmation_of_grad_school_signoff', entity: work, acting_as: ['creating_user', 'etd_reviewer', 'advisor'])
          subject.submit(requested_by: user)
        end
      end
    end
  end
end
