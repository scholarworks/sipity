require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe WorkEnrichmentForm do
      let(:work) { Models::Work.new(id: '1234') }
      subject { described_class.new(work: work) }

      its(:policy_enforcer) { should eq Policies::Processing::WorkProcessingPolicy }

      it { should respond_to :to_processing_entity }

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
          subject { described_class.new(work: work) }

          before do
            expect(subject).to receive(:valid?).and_return(true)
          end

          it 'will return the work' do
            returned_value = subject.submit(repository: repository, requested_by: user)
            expect(returned_value).to eq(work)
          end

          it "will transition the work's corresponding enrichment todo item to :done" do
            expect(repository).to receive(:mark_work_todo_item_as_done).and_call_original
            subject.submit(repository: repository, requested_by: user)
          end

          it 'will record the event' do
            expect(repository).to receive(:log_event!).and_call_original
            subject.submit(repository: repository, requested_by: user)
          end
        end
      end
    end
  end
end
