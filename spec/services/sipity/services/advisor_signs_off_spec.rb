module Sipity
  module Services
    RSpec.describe AdvisorSignsOff do
      let(:form) { double('Form', resulting_strategy_state: 'chubacabra') }
      let(:repository) { CommandRepositoryInterface.new }
      let(:requested_by) { double('User') }

      subject { described_class.new(form: form, repository: repository, requested_by: requested_by) }

      context 'when there are other advisors that have not yet signed-off' do
        before { expect(subject).to receive(:is_last_advisor_to_signoff?).and_return(false) }
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
        before { expect(subject).to receive(:is_last_advisor_to_signoff?).and_return(true) }
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
    end
  end
end
