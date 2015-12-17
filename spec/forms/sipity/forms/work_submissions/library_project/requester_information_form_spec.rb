require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/library_project/requester_information_form'

module Sipity
  module Forms
    module WorkSubmissions
      module LibraryProject
        RSpec.describe RequesterInformationForm do
          let(:user) { double('User') }
          let(:work) { double('Work', title: 'The work title') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { { library_program_name: 'Academic Outreach and Engagement' } }
          let(:keywords) { { requested_by: user, attributes: attributes, work: work, repository: repository } }
          subject { described_class.new(keywords) }

          include Shoulda::Matchers::ActiveModel
          it { should validate_presence_of(:library_program_name) }
          it { should validate_inclusion_of(:library_program_name).in_array(subject.library_program_name_for_select) }

          context '#initialization without attributes given' do
            subject { described_class.new(requested_by: user, attributes: {}, work: work, repository: repository) }

            it "will fetch the additional attributes from the repository" do
              expect(repository).to receive(:work_attribute_values_for).
                with(work: work, key: 'library_program_name', cardinality: 1).and_return("a library_program_name")
              subject = described_class.new(requested_by: user, attributes: {}, work: work, repository: repository)
              expect(subject.library_program_name).to eq('a library_program_name')
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

              it 'will update the library_program_name' do
                expect(repository).to receive(:update_work_attribute_values!).with(
                  work: work, key: 'library_program_name', values: attributes.fetch(:library_program_name)
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
