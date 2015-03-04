module Sipity
  module Services
    RSpec.describe AdvisorSignsOff do
      let(:form) { double('Form', resulting_strategy_state: 'chubacabra') }
      let(:repository) { CommandRepositoryInterface.new }
      let(:requested_by) { double('User') }

      subject { described_class.new(form: form, repository: repository, requested_by: requested_by) }

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
          expect(repository).to receive(:send_notification_for_entity_trigger).
            with(notification: 'advisor_signoff_but_still_more_to_go', entity: form, acting_as: 'creating_user')
          subject.call
        end
      end

      context 'when this is the last advisor to signoff' do
        before { expect(subject).to receive(:last_advisor_to_signoff?).and_return(true) }
        it 'will change the processing state' do
          expect(repository).to receive(:update_processing_state!).and_call_original
          subject.call
        end
        it 'will send emails to the etd_reviewers and creating user' do
          expect(repository).to receive(:send_notification_for_entity_trigger).
            with(notification: 'entity_ready_for_review', entity: form, acting_as: 'etd_reviewer')
          expect(repository).to receive(:send_notification_for_entity_trigger).
            with(notification: 'all_advisors_have_signed_off', entity: form, acting_as: 'creating_user')
          subject.call
        end
      end

      # Even though this is a private method I want to verify my personal logic.
      context '#last_advisor_to_signoff?' do
        [
          { collaborating_reviewer_usernames: ['bob'], usernames_for_those_that_have_acted: ['alice'], expected: false },
          { collaborating_reviewer_usernames: ['alice'], usernames_for_those_that_have_acted: ['alice'], expected: true },
          { collaborating_reviewer_usernames: ['alice', 'bob'], usernames_for_those_that_have_acted: ['alice'], expected: false },
          { collaborating_reviewer_usernames: ['alice', 'bob'], usernames_for_those_that_have_acted: ['alice', 'bob'], expected: true },
          { collaborating_reviewer_usernames: ['carol', 'bob'], usernames_for_those_that_have_acted: ['alice', 'bob'], expected: false },
          { collaborating_reviewer_usernames: [], usernames_for_those_that_have_acted: ['alice', 'bob'], expected: true },
          { collaborating_reviewer_usernames: [], usernames_for_those_that_have_acted: [], expected: true },
          { collaborating_reviewer_usernames: ['bob'], usernames_for_those_that_have_acted: [], expected: false }
        ].each_with_index do |example, index|
          it "will handle #{example.inspect} (Scenario ##{index})" do
            expect(subject).to receive(:collaborating_reviewer_usernames).
              and_return(example.fetch(:collaborating_reviewer_usernames))
            expect(subject).to receive(:usernames_for_those_that_have_acted).
              and_return(example.fetch(:usernames_for_those_that_have_acted))
            expect(subject.send(:last_advisor_to_signoff?)).to eq(example.fetch(:expected))
          end
        end
      end

      context 'default repository' do
        let(:form) { double('Form', resulting_strategy_state: 'chubacabra', action: 'submit_for_review', work: double) }
        subject { described_class.new(form: form, requested_by: requested_by) }
        it 'exposes #usernames_of_those_that_have_taken_the_action_on_the_entity' do
          expect(subject.send(:repository)).to receive(:usernames_of_those_that_have_taken_the_action_on_the_entity)
          subject.send(:usernames_for_those_that_have_acted)
        end

        it 'exposes #usernames_of_those_that_are_collaborating_and_responsible_for_review' do
          expect(subject.send(:repository)).to receive(:usernames_of_those_that_are_collaborating_and_responsible_for_review)
          subject.send(:collaborating_reviewer_usernames)
        end
      end
    end
  end
end
