require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe DefenseDateForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:defense_date) { Time.zone.today }
          let(:repository) { CommandRepositoryInterface.new }
          subject { described_class.new(work: work, repository: repository) }

          its(:enrichment_type) { should eq('defense_date') }
          its(:policy_enforcer) { should eq Policies::WorkPolicy }

          it { should respond_to :work }
          it { should respond_to :defense_date }

          it 'will require a defense_date' do
            subject.valid?
            expect(subject.errors[:defense_date]).to be_present
          end

          it 'will handle Rails defense_date that was input via Rails HTML multi-field date input' do
            form = described_class.new(
              work: work, repository: repository, attributes: {
                'defense_date(1i)' => "2014", 'defense_date(2i)' => "10", 'defense_date(3i)' => "1"
              }
            )
            expect(form.defense_date.month).to eq(10)
          end

          context '#defense_date' do
            context 'with data from the database' do
              subject { described_class.new(work: work, repository: repository) }
              it 'will return the defense_date of the work' do
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'defense_date').and_return([defense_date])
                expect(subject.defense_date).to eq defense_date
              end
            end
            context 'when initial date is given is bogus' do
              subject { described_class.new(work: work, defense_date: '2014-02-31', repository: repository) }
              its(:defense_date) { should_not be_present }
            end
          end

          context '#submit' do
            let(:user) { double('User') }
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit(requested_by: user))
              end
            end

            context 'with valid data' do
              subject { described_class.new(work: work, defense_date: '2014-10-02', repository: repository) }
              before do
                expect(subject).to receive(:valid?).and_return(true)
              end

              it 'will return the work' do
                returned_value = subject.submit(requested_by: user)
                expect(returned_value).to eq(work)
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).and_call_original
                subject.submit(requested_by: user)
              end
            end
          end
        end
      end
    end
  end
end
