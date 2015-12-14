require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/ulra/plan_of_study_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe PlanOfStudyForm do
          let(:user) { double('User') }
          let(:work) { double('Work') }
          let(:expected_graduation_date) { Time.zone.today }
          let(:majors) { 'Computer Science' }
          let(:minors) { 'A Minor' }
          let(:college) { 'Arts and Letters' }
          let(:repository) { CommandRepositoryInterface.new }
          let(:keywords) { { requested_by: user, attributes: {}, work: work, repository: repository } }
          subject { described_class.new(keywords) }

          before do
            allow(repository).to receive(
              :get_controlled_vocabulary_values_for_predicate_name
            ).with(name: 'college').and_return([college])
          end

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

          include Shoulda::Matchers::ActiveModel
          it { should validate_presence_of(:expected_graduation_date) }
          it { should validate_presence_of(:college) }
          it { should validate_inclusion_of(:college).in_array(subject.possible_colleges) }

          it 'will be invalid if all of the input majors are blank' do
            subject = described_class.new(keywords.merge(attributes: { majors: ['', ''] }))
            subject.valid?
            expect(subject.errors[:majors]).to be_present
          end

          it 'will be valid if at least one of the input majors is not blank' do
            subject = described_class.new(keywords.merge(attributes: { majors: ['chocolate', ''] }))
            subject.valid?
            expect(subject.errors[:majors]).to_not be_present
          end

          context 'retrieving values from the repository' do
            context 'with data from the database' do
              let(:expected_graduation_date) { Time.zone.today }
              let(:majors) { 'Computer Science' }
              let(:minors) { 'Book' }
              subject { described_class.new(keywords) }
              it 'will return the expected_graduation_date of the work' do
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'expected_graduation_date', cardinality: 1).and_return(expected_graduation_date)
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'majors', cardinality: :many).and_return([majors])
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'minors', cardinality: :many).and_return([minors])
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'college', cardinality: 1).and_return(college)

                expect(subject.expected_graduation_date).to eq expected_graduation_date
                expect(subject.majors).to eq [majors]
                expect(subject.minors).to eq [minors]
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
                described_class.new(
                  keywords.merge(
                    attributes: { expected_graduation_date: expected_graduation_date, majors: majors, minors: minors, college: college }
                  )
                )
              end
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).with(
                  work: work, key: 'expected_graduation_date', values: expected_graduation_date
                ).and_call_original
                expect(repository).to receive(:update_work_attribute_values!).with(
                  work: work, key: 'majors', values: [majors]
                ).and_call_original
                expect(repository).to receive(:update_work_attribute_values!).with(
                  work: work, key: 'minors', values: [minors]
                ).and_call_original
                expect(repository).to receive(:update_work_attribute_values!).with(
                  work: work, key: 'college', values: college
                ).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
