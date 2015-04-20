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
        subject { described_class.new(work: work, processing_action_name: action, agree_to_signoff: true, repository: repository) }

        its(:processing_action_name) { should eq(action.name) }

        context 'processing_action_name to action conversion' do
          it 'will use the given action if the strategy matches' do
            subject = described_class.new(work: work, processing_action_name: action, repository: repository)
            expect(subject.action).to eq(action)
          end
        end

        context 'validation' do
          it 'will require agreement to the signoff' do
            subject = described_class.new(work: work, processing_action_name: action, repository: repository)
            subject.valid?
            expect(subject.errors[:agree_to_signoff]).to be_present
          end
        end

        context '#render' do
          it 'will render HTML safe submission terms and confirmation' do
            form_object = double('Form Object')
            expect(form_object).to receive(:input).with(:agree_to_signoff, hash_including(as: :boolean)).and_return("<input />")
            expect(subject.render(f: form_object)).to be_html_safe
          end
        end

        its(:legend) { should be_html_safe }
        its(:signoff_agreement) { should be_html_safe }

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
          expect(repository).to receive(:deliver_form_submission_notifications_for).
            with(scope: action, the_thing: work, requested_by: user)
          subject.submit(requested_by: user)
        end
      end
    end
  end
end
