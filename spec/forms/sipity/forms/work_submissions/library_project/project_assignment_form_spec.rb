require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/library_project/project_assignment_form'

module Sipity
  module Forms
    module WorkSubmissions
      module LibraryProject
        RSpec.describe ProjectAssignmentForm do
          let(:user) { double('User') }
          let(:work) { double('Work', title: 'The work title') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) do
            {
              project_issue_type: 'Strategic Initiative', project_assigned_to_person: 'Robert Bork'
            }
          end
          let(:keywords) { { requested_by: user, attributes: attributes, work: work, repository: repository } }
          subject { described_class.new(keywords) }

          include Shoulda::Matchers::ActiveModel
          it { should validate_presence_of(:project_assigned_to_person) }
          it { should validate_presence_of(:project_issue_type) }
          it { should validate_inclusion_of(:project_issue_type).in_array(subject.project_issue_type_for_select) }

          context '#initialization without attributes given' do
            subject { described_class.new(requested_by: user, attributes: {}, work: work, repository: repository) }

            it "will fetch the additional attributes from the repository" do
              [
                'project_issue_type', 'project_assigned_to_person'
              ].each do |attribute_name|
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: attribute_name.to_s, cardinality: 1).and_return("a #{attribute_name}")
              end
              subject = described_class.new(requested_by: user, attributes: {}, work: work, repository: repository)
              expect(subject.project_issue_type).to eq('a project_issue_type')
              expect(subject.project_assigned_to_person).to eq('a project_assigned_to_person')
            end
          end

          context '#submit' do
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              its(:submit) { should eq(false) }
            end
            context 'with valid data' do
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield.and_return(work)
              end
              its(:submit) { should eq(work) }

              it 'will update the additional attributes' do
                [
                  'project_issue_type', 'project_assigned_to_person'
                ].each do |attribute_name|
                  expect(repository).to receive(:update_work_attribute_values!).with(
                    work: work, key: attribute_name, values: attributes.fetch(attribute_name.to_sym)
                  ).and_call_original
                end
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
