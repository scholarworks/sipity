module Sipity
  module Services
    RSpec.describe RequestChangesViaCommentService do
      let(:form) do
        double(
          'Form',
          work: double,
          comment: 'This is a comment',
          enrichment_type: 'hello',
          action: action,
          event_name: 'hello_event'
        )
      end
      let(:action) { Models::Processing::StrategyAction.new }
      let(:on_behalf_of) { Models::Processing::Actor.new(id: 2) }
      let(:repository) { CommandRepositoryInterface.new }
      let(:requested_by) { Models::Processing::Actor.new(id: 1) }
      let(:base_options) { { form: form, repository: repository, requested_by: requested_by, on_behalf_of: on_behalf_of } }
      subject { described_class.new(base_options) }

      context '.call' do
        it 'is a wrapper' do
          expect_any_instance_of(described_class).to receive(:call)
          described_class.call(base_options)
        end
      end

      its(:default_repository) { should respond_to :record_processing_comment }

      context 'with valid data' do
        subject { described_class.new(base_options) }
        let(:a_processing_comment) { double }
        before do
          allow(repository).to receive(:record_processing_comment).and_return(a_processing_comment)
        end

        it 'will log the event' do
          expect(repository).to receive(:log_event!).and_call_original
          subject.call
        end

        it 'will update the processing state' do
          strategy_state = action.build_resulting_strategy_state
          expect(repository).to receive(:update_processing_state!).
            with(entity: form.work, to: strategy_state).and_call_original
          subject.call
        end

        it 'will register the action' do
          expect(repository).to receive(:register_action_taken_on_entity).
            with(work: form.work, enrichment_type: form.enrichment_type, requested_by: requested_by, on_behalf_of: on_behalf_of).
            and_call_original
          subject.call
        end

        it 'will record the processing comment' do
          expect(repository).to receive(:record_processing_comment).and_return(a_processing_comment)
          subject.call
        end

        it 'will send creating user a note that the advisor has requested changes' do
          expect(repository).to receive(:deliver_notification_for).
            with(scope: action, the_thing: a_processing_comment, requested_by: requested_by, on_behalf_of: on_behalf_of).
            and_call_original
          subject.call
        end
      end
    end
  end
end
