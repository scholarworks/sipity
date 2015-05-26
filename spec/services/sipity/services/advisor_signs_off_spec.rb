module Sipity
  module Services
    RSpec.describe AdvisorSignsOff do
      let(:form) { double('Form', resulting_strategy_state: 'chubacabra', action: 'an_action') }
      let(:on_behalf_of) { double('Collaborator') }
      let(:repository) { CommandRepositoryInterface.new }
      let(:requested_by) { double('User') }

      subject { described_class.new(form: form, repository: repository, requested_by: requested_by, on_behalf_of: on_behalf_of) }

      it 'will default the on_behalf_of to the requested_by if none is given' do
        subject = described_class.new(form: form, repository: repository, requested_by: requested_by)
        expect(subject.on_behalf_of).to eq(requested_by)
      end

      context '.call' do
        it 'is a wrapper' do
          expect_any_instance_of(described_class).to receive(:call)
          described_class.call(form: form, repository: repository, requested_by: requested_by)
        end
      end

      context 'when there are other advisors that have not yet signed-off' do
        before { expect(subject).to receive(:last_advisor_to_signoff?).and_return(false) }
        it 'will NOT change the processing state' do
          expect(repository).to_not receive(:update_processing_state!)
          subject.call
        end
        it 'will send an email to the creating user' do
          expect(repository).to receive(:deliver_notification_for).
            with(the_thing: form, scope: form.action, requested_by: requested_by, on_behalf_of: on_behalf_of)
          subject.call
        end
      end

      context 'when this is the last advisor to signoff' do
        before { expect(subject).to receive(:last_advisor_to_signoff?).and_return(true) }
        it 'will change the processing state' do
          expect(repository).to receive(:update_processing_state!).and_call_original
          subject.call
        end
        it 'will deliver form submission notifications' do
          expect(repository).to receive(:deliver_notification_for).
            with(the_thing: form, scope: form.action, requested_by: requested_by, on_behalf_of: on_behalf_of)
          subject.call
        end
      end

      # Even though this is a private method I want to verify my personal logic.
      context '#last_advisor_to_signoff?' do
        [
          { reviewers: ['bob'], already_reviewed: ['alice'], expected: false },
          { reviewers: ['alice'], already_reviewed: ['alice'], expected: true },
          { reviewers: ['alice', 'bob'], already_reviewed: ['alice'], expected: false },
          { reviewers: ['alice', 'bob'], already_reviewed: ['alice', 'bob'], expected: true },
          { reviewers: ['carol', 'bob'], already_reviewed: ['alice', 'bob'], expected: false },
          { reviewers: [], already_reviewed: ['alice', 'bob'], expected: true },
          { reviewers: [], already_reviewed: [], expected: true },
          { reviewers: ['bob'], already_reviewed: [], expected: false }
        ].each_with_index do |example, index|
          it "will handle #{example.inspect} (Scenario ##{index})" do
            expect(subject).to receive(:work_collaborators_responsible_for_review).
              and_return(example.fetch(:reviewers))
            expect(subject).to receive(:collaborators_that_have_taken_the_action_on_the_entity).
              and_return(example.fetch(:already_reviewed))
            expect(subject.send(:last_advisor_to_signoff?)).to eq(example.fetch(:expected))
          end
        end
      end

      context 'default repository' do
        let(:form) { double('Form', resulting_strategy_state: 'chubacabra', registered_action: 'submit_for_review', work: double) }
        subject { described_class.new(form: form, requested_by: requested_by) }
        it 'exposes #collaborators_that_have_taken_the_action_on_the_entity' do
          expect(subject.send(:repository)).to receive(:collaborators_that_have_taken_the_action_on_the_entity)
          subject.send(:collaborators_that_have_taken_the_action_on_the_entity)
        end

        it 'exposes #work_collaborators_responsible_for_review' do
          expect(subject.send(:repository)).to receive(:work_collaborators_responsible_for_review)
          subject.send(:work_collaborators_responsible_for_review)
        end
      end
    end
  end
end
