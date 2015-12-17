require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/library_project/project_information_form'

module Sipity
  module Forms
    module WorkSubmissions
      module LibraryProject
        RSpec.describe ProjectInformationForm do
          let(:user) { double('User') }
          let(:work) { double('Work', title: 'The work title') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) do
            {
              title: 'The title', project_description: 'Hello World', project_impact: 'Its really important',
              whom_does_this_impract: 'Whom does this impact', project_management_services_requested: 'Yes', project_priority: 'Low'
            }
          end
          let(:keywords) { { requested_by: user, attributes: attributes, work: work, repository: repository } }
          subject { described_class.new(keywords) }


          include Shoulda::Matchers::ActiveModel
          it { should validate_presence_of(:title) }
          it { should validate_presence_of(:project_description) }
          it { should validate_presence_of(:project_impact) }
          it { should validate_presence_of(:whom_does_this_impract) }
          it { should validate_presence_of(:project_priority) }
          it { should validate_inclusion_of(:project_priority).in_array(subject.project_priority_for_select) }
          it { should validate_presence_of(:project_management_services_requested) }
          it do
            should validate_inclusion_of(:project_management_services_requested).
              in_array(subject.project_management_services_requested_for_select)
          end

          context '#initialization without attributes given' do
            subject { described_class.new(requested_by: user, attributes: {}, work: work, repository: repository) }
            it 'will fetch the title from the work' do
              expect(subject.title).to eq(work.title)
            end

            it "will fetch the additional attributes from the repository" do
              [
                'project_description', 'project_impact', 'whom_does_this_impract', 'project_management_services_requested',
                'project_priority'
              ].each do |attribute_name|
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: attribute_name.to_s, cardinality: 1).and_return("a #{attribute_name}")
              end
              subject = described_class.new(requested_by: user, attributes: {}, work: work, repository: repository)
              expect(subject.project_description).to eq('a project_description')
              expect(subject.project_impact).to eq('a project_impact')
              expect(subject.whom_does_this_impract).to eq('a whom_does_this_impract')
              expect(subject.project_management_services_requested).to eq('a project_management_services_requested')
              expect(subject.project_priority).to eq('a project_priority')
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

              it 'will update the title' do
                expect(repository).to receive(:update_work_title!).with(work: work, title: attributes.fetch(:title))
                subject.submit
              end

              it 'will update the additional attributes' do
                [
                  'project_description', 'project_priority', 'project_impact', 'whom_does_this_impract',
                  'project_management_services_requested'
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
