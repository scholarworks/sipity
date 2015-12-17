require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/library_project/completion_requirement_form'

module Sipity
  module Forms
    module WorkSubmissions
      module LibraryProject
        RSpec.describe CompletionRequirementForm do
          let(:user) { double('User') }
          let(:work) { double('Work', title: 'The work title') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:as_of) { Date.today }
          let(:attributes) { { project_must_complete_by_date: as_of, project_must_complete_by_reason: 'The reason' } }
          let(:keywords) { { requested_by: user, attributes: attributes, work: work, repository: repository } }
          subject { described_class.new(keywords) }


          include Shoulda::Matchers::ActiveModel
          it { should validate_presence_of(:project_must_complete_by_date) }
          it { should validate_presence_of(:project_must_complete_by_reason) }

          context '#initialization without attributes given' do
            subject { described_class.new(requested_by: user, attributes: {}, work: work, repository: repository) }

            it "will fetch the additional attributes from the repository" do
              expect(repository).to receive(:work_attribute_values_for).
                with(work: work, key: 'project_must_complete_by_date', cardinality: 1).and_return(as_of)
              expect(repository).to receive(:work_attribute_values_for).
                with(work: work, key: 'project_must_complete_by_reason', cardinality: 1).and_return('a reason')

              subject = described_class.new(requested_by: user, attributes: {}, work: work, repository: repository)
              expect(subject.project_must_complete_by_date).to eq(as_of)
              expect(subject.project_must_complete_by_reason).to eq('a reason')
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
                ['project_must_complete_by_date', 'project_must_complete_by_reason'].each do |attribute_name|
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
