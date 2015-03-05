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
        subject { described_class.new(work: work, processing_action_name: action, repository: repository) }

        it 'validates the aggreement to the submission terms' do
          subject = described_class.new(work: work, processing_action_name: action, repository: repository)
          subject.valid?
          expect(subject.errors[:agree_to_terms_of_deposit]).to be_present
        end

        context 'processing_action_name to action conversion' do
          it 'will use the given action if the strategy matches' do
            subject = described_class.new(work: work, processing_action_name: action, repository: repository)
            expect(subject.action).to eq(action)
          end
        end

        context '#render' do
          it 'will render HTML safe submission terms and confirmation' do
            form_object = double('Form Object')
            expect(form_object).to receive(:input).with(:agree_to_terms_of_deposit, hash_including(as: :boolean)).and_return("<input />")
            expect(subject.render(f: form_object)).to be_html_safe
          end
        end

        its(:deposit_terms_heading) { should be_html_safe }
        its(:deposit_terms) { should be_html_safe }
        its(:deposit_agreement) { should be_html_safe }

        context 'with valid data' do
          subject do
            described_class.new(work: work, processing_action_name: action, repository: repository, agree_to_terms_of_deposit: true)
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

          it 'will send differing notifications to the creating user, etd reviewer, and advisor' do
            expect(repository).to receive(:send_notification_for_entity_trigger).
              with(notification: 'confirmation_of_entity_submitted_for_review', entity: work, acting_as: 'creating_user')
            expect(repository).to receive(:send_notification_for_entity_trigger).
              with(notification: 'entity_ready_for_review', entity: work, acting_as: ['etd_reviewer', 'advisor'])
            subject.submit(requested_by: user)
          end
        end
      end
    end
  end
end
