require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe PlanOfStudyForm do
          let(:user) { double('User') }
          let(:work) { double('Work') }
          let(:expected_graduation_date) { Time.zone.today }
          let(:majors) { 'Computer Science' }
          let(:repository) { CommandRepositoryInterface.new }
          let(:keywords) { { requested_by: user, attributes: {}, work: work, repository: repository } }
          subject { described_class.new(keywords) }

          its(:processing_action_name) { should eq('plan_of_study') }
          its(:policy_enforcer) { should eq Policies::WorkPolicy }
          its(:base_class) { should eq(Models::Work) }

          context 'class configuration' do
            subject { described_class }
            its(:model_name) { should eq(Models::Work.model_name) }
            it 'will delegate human_attribute_name to the base class' do
              expect(described_class.base_class).to receive(:human_attribute_name).and_call_original
              expect(described_class.human_attribute_name(:title)).to be_a(String)
            end
          end

          it { should_not be_persisted }
          it { should respond_to :work }
          it { should respond_to :expected_graduation_date }
          it { should respond_to :majors }

          it 'will require a expected_graduation_date' do
            subject.valid?
            expect(subject.errors[:expected_graduation_date]).to be_present
          end

          it 'will require a major' do
            subject.valid?
            expect(subject.errors[:majors]).to be_present
          end

          it 'will require at least one non-blank major' do
            subject = described_class.new(keywords.merge(attributes: { majors: ['', ''] }))
            subject.valid?
            expect(subject.errors[:majors]).to be_present
          end

          it 'will require at least one non-blank major' do
            subject = described_class.new(keywords.merge(attributes: { majors: ['chocolate', ''] }))
            subject.valid?
            expect(subject.errors[:majors]).to_not be_present
          end

          context 'retrieving values from the repository' do
            context 'with data from the database' do
              let(:expected_graduation_date) { Time.zone.today }
              let(:majors) { 'Computer Science' }
              subject { described_class.new(keywords) }
              it 'will return the expected_graduation_date of the work' do
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'expected_graduation_date').and_return(expected_graduation_date)
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'majors').and_return([majors])
                expect(subject.expected_graduation_date).to eq expected_graduation_date
                expect(subject.majors).to eq [majors]
              end
            end
            context 'when initial date is given is bogus' do
              subject { described_class.new(keywords.merge(attributes: { expected_graduation_date: '2014-02-31' })) }
              its(:expected_graduation_date) { should_not be_present }
            end
          end
          context '#submit' do
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit)
              end
            end

            context 'with valid data' do
              subject do
                described_class.new(keywords.merge(attributes: { expected_graduation_date: expected_graduation_date, majors: majors }))
              end
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).exactly(2).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
