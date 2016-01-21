require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/ulra/faculty_response_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe FacultyResponseForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:keywords) { { work: work, repository: repository, requested_by: user } }
          let(:user) { double('User') }
          subject { described_class.new(keywords) }

          its(:processing_action_name) { should eq('faculty_response') }
          its(:policy_enforcer) { should eq Policies::WorkPolicy }
          its(:base_class) { should eq(Models::Work) }
          its(:attachment_predicate_name) { should eq('faculty_letter_of_recommendation') }

          context 'class configuration' do
            subject { described_class }
            its(:model_name) { should eq(Models::Work.model_name) }
            it 'will delegate human_attribute_name to the base class' do
              expect(described_class.base_class).to receive(:human_attribute_name).and_call_original
              expect(described_class.human_attribute_name(:title)).to be_a(String)
            end
          end

          it { should respond_to :work }
          it { should_not be_persisted }

          it { should delegate_method(:at_least_one_file_must_be_attached).to(:attachments_extension) }

          it 'will have #attachments' do
            attachment = [double('Attachment')]
            expect(repository).to receive(:work_attachments).and_return(attachment)
            expect(subject.attachments).to_not be_empty
          end

          context '#submit' do
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit).to eq(false)
              end
            end

            context 'with valid data' do
              subject { described_class.new(keywords.merge(attributes: { files: [double] })) }

              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will attach or update files' do
                expect(subject.send(:attachments_extension)).to receive(:attach_or_update_files).with(requested_by: user)
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
