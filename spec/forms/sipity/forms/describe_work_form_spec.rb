require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe DescribeWorkForm do
      let(:work) { Models::Work.new(id: '1234') }
      subject { described_class.new(work: work) }

      its(:policy_enforcer) { should eq Policies::EnrichWorkByFormSubmissionPolicy }

      it { should respond_to :work }
      it { should respond_to :abstract }
      it { should respond_to :abstract= }

      it 'will require a abstract' do
        subject.valid?
        expect(subject.errors[:abstract]).to be_present
      end

      it 'will require a work' do
        subject = described_class.new(work: nil)
        subject.valid?
        expect(subject.errors[:work]).to_not be_empty
      end

      context '#submit' do
        let(:repository) { double('Repository', log_event!: true, update_work_attribute_values!: true) }
        let(:user) { double('User') }
        context 'with invalid data' do
          before do
            expect(subject).to receive(:valid?).and_return(false)
          end
          it 'will return false if not valid' do
            expect(subject.submit(repository: repository, requested_by: user))
          end
          it 'will not create create any additional attributes entries' do
            expect { subject.submit(repository: repository, requested_by: user) }.
              to_not change { Models::AdditionalAttribute.count }
          end
        end

        context 'with valid data' do
          subject { described_class.new(work: work, abstract: 'Hello Dolly') }
          before do
            expect(subject).to receive(:valid?).and_return(true)
          end

          it 'will return the work' do
            returned_value = subject.submit(repository: repository, requested_by: user)
            expect(returned_value).to eq(work)
          end

          it 'will add additional attributes entries' do
            subject.submit(repository: repository, requested_by: user)
            expect(repository).to have_received(:update_work_attribute_values!).
              with(work: work, key: 'abstract', values: subject.abstract)
          end

          it 'will record the event' do
            subject.submit(repository: repository, requested_by: user)
            expect(repository).to have_received(:log_event!).with(entity: work, user: user, event_name: 'describe_work_form/submit')
          end
        end

      end
    end
  end
end
