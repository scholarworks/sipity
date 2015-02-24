require 'spec_helper'

module Sipity
  module Forms
    module WorkEnrichments
      RSpec.describe DefenseDateForm do
        let(:work) { Models::Work.new(id: '1234') }
        let(:defense_date) { Date.today }
        subject { described_class.new(work: work) }

        its(:enrichment_type) { should eq('defense_date') }
        its(:policy_enforcer) { should eq Policies::Processing::WorkProcessingPolicy }

        it { should respond_to :work }
        it { should respond_to :defense_date }
        it { should respond_to :defense_date= }

        it 'will require a defense_date' do
          subject.valid?
          expect(subject.errors[:defense_date]).to be_present
        end

        context '#defense_date' do
          subject { described_class.new(work: work) }
          it 'will return the defense_date of the work' do
            expect(Queries::AdditionalAttributeQueries).to receive(:work_attribute_values_for).
              with(work: work, key: 'defense_date').and_return([defense_date])
            expect(subject.defense_date).to eq defense_date
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
              expect(subject.submit(repository: repository, requested_by: user))
            end
          end

          context 'with valid data' do
            subject { described_class.new(work: work, defense_date: '2014-10-02') }
            before do
              expect(subject).to receive(:valid?).and_return(true)
            end

            it 'will return the work' do
              returned_value = subject.submit(repository: repository, requested_by: user)
              expect(returned_value).to eq(work)
            end

            it "will transition the work's corresponding enrichment todo item to :done" do
              expect(repository).to receive(:register_action_taken_on_entity).and_call_original
              subject.submit(repository: repository, requested_by: user)
            end

            it 'will add additional attributes entries' do
              expect(repository).to receive(:update_work_attribute_values!).and_call_original
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
end
