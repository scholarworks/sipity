require 'spec_helper'

module Sipity
  module Forms
    module Etd
      RSpec.describe AdvisorRequestsChangeForm do
        let(:processing_entity) { Models::Processing::Entity.new(strategy_id: 1) }
        let(:work) { double('Work', to_processing_entity: processing_entity) }
        let(:repository) { CommandRepositoryInterface.new }
        let(:action) { Models::Processing::StrategyAction.new(strategy_id: processing_entity.strategy_id, name: 'hello') }
        let(:user) { User.new(id: 1) }
        subject { described_class.new(work: work, processing_action_name: action, repository: repository) }

        its(:processing_action_name) { should eq(action.name) }
        its(:event_name) { should eq('etd/advisor_requests_change_form/submit') }

        context '#render' do
          let(:f) { double }
          it 'will return an input text area' do
            expect(f).to receive(:input).with(:comment, hash_including(as: :text))
            subject.render(f: f)
          end
        end

        its(:advisor_requests_change_legend) { should be_html_safe }

        context 'processing_action_name to action conversion' do
          it 'will use the given action if the strategy matches' do
            subject = described_class.new(work: work, processing_action_name: action, repository: repository)
            expect(subject.action).to eq(action)
          end
        end

        context 'with valid data' do
          let(:a_processing_comment) { double }
          before do
            allow(repository).to receive(:record_processing_comment).and_return(a_processing_comment)
            expect(subject).to receive(:valid?).and_return(true)
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

          it 'will deliver form submission notifications for' do
            expect(repository).to receive(:deliver_form_submission_notifications_for).and_call_original
            subject.submit(requested_by: user)
          end

          it 'will record the processing comment' do
            expect(repository).to receive(:record_processing_comment).and_return(a_processing_comment)
            subject.submit(requested_by: user)
          end
        end
      end
    end
  end
end
