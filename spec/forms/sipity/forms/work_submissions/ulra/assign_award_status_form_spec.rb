require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/ulra/assign_award_status_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe AssignAwardStatusForm do
          let(:user) { double('User') }
          let(:work) { double('Work') }
          let(:is_an_award_winner) { 'Yes' }
          let(:repository) { CommandRepositoryInterface.new }
          let(:keywords) { { requested_by: user, attributes: {}, work: work, repository: repository } }
          subject { described_class.new(keywords) }

          its(:processing_action_name) { should eq('assign_award_status') }
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
          it { should respond_to :is_an_award_winner }

          include Shoulda::Matchers::ActiveModel
          it { should validate_presence_of(:is_an_award_winner) }
          it { should validate_inclusion_of(:is_an_award_winner).in_array(subject.possible_is_an_award_winner) }

          context 'retrieving values from the repository' do
            context 'with data from the database' do
              let(:is_an_award_winner) { 'No' }
              subject { described_class.new(keywords) }
              it 'will return the expected_graduation_term of the work' do
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'is_an_award_winner', cardinality: 1).and_return(is_an_award_winner)

                expect(subject.is_an_award_winner).to eq(is_an_award_winner)
              end
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
              subject { described_class.new(keywords.merge(attributes: { is_an_award_winner: 'Yes' })) }
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).with(
                  work: work, key: 'is_an_award_winner', values: 'Yes'
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
