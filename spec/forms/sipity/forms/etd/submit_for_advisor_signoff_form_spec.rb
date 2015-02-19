require 'spec_helper'

module Sipity
  module Forms
    module Etd
      RSpec.describe SubmitForAdvisorSignoffForm do
        let(:work) { double('Work') }
        let(:repository) { CommandRepositoryInterface.new }
        let(:action) { Models::Processing::StrategyAction.new }
        let(:user) { User.new(id: 1) }
        subject { described_class.new(work: work, action: action) }

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
