require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe WorkEventTriggerForm do
      let(:work) { Models::Work.new(id: '1234') }
      let(:event_receiver) { StateMachines::Interface }
      subject { described_class.new(work: work, event_name: 'submit_for_review', event_receiver: event_receiver) }

      its(:policy_enforcer) { should eq(Policies::EnrichWorkByFormSubmissionPolicy) }

      context 'with defaults' do
        subject { described_class.new(work: work, event_name: 'submit_for_review') }
        its(:event_receiver) { should respond_to :trigger! }
      end

      context 'validations' do
        it 'will require a work' do
          subject = described_class.new(work: nil)
          subject.valid?
          expect(subject.errors[:work]).to_not be_empty
        end
      end

      context '#submit' do
        let(:repository) { CommandRepositoryInterface.new }
        let(:user) { double('User') }
        context 'with invalid data' do
          before do
            expect(subject).to receive(:valid?).and_return(false)
          end
          it 'will return false if not valid' do
            expect(subject.submit(repository: repository, requested_by: user)).to eq(false)
          end
          it 'will not attempt to save the form' do
            expect(subject).to_not receive(:save)
            subject.submit(repository: repository, requested_by: user)
          end
        end

        context 'with valid data' do
          before do
            expect(subject.event_receiver).to receive(:trigger!)
            expect(subject).to receive(:valid?).and_return(true)
          end

          it 'will return the work' do
            returned_value = subject.submit(repository: repository, requested_by: user)
            expect(returned_value).to eq(work)
          end

          it 'will build an event object and trigger it' do
            subject.submit(repository: repository, requested_by: user)
          end
        end
      end
    end
  end
end
