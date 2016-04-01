require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/core/attach_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        RSpec.describe AttachForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double }
          let(:keywords) { { work: work, repository: repository, requested_by: user, attributes: attributes } }
          let(:attributes) { {} }
          subject { described_class.new(keywords) }

          its(:policy_enforcer) { is_expected.to be_present }
          its(:processing_action_name) { is_expected.to eq('attach') }

          it { is_expected.to respond_to :attachments }
          it { is_expected.to respond_to :representative_attachment_id }
          it { is_expected.to respond_to :files }

          it { is_expected.to delegate_method(:at_least_one_file_must_be_attached).to(:attachments_extension) }
          it { is_expected.to delegate_method(:attachments_associated_with_the_work?).to(:attachments_extension) }

          context 'validations' do
            it 'will require a work' do
              subject = described_class.new(keywords.merge(work: nil))
              subject.valid?
              expect(subject.errors[:work]).to_not be_empty
            end

            it 'will have #representative_for_attachment_id' do
              representative_for_attachment = [double('Attachment')]
              expect(repository).to receive(:representative_attachment_for).
                with(work: work).and_return(representative_for_attachment)
              subject.representative_attachment_id
            end

            it 'will have #attachments' do
              attachment = [double('Attachment')]
              expect(repository).to receive(:work_attachments).and_return(attachment)
              expect(subject.attachments).to_not be_empty
            end
          end

          context 'assigning attachments attributes' do
            let(:user) { double('User') }
            let(:attributes) do
              {
                attachments_attributes:
                {
                  "0" => { "name" => "code4lib.pdf", "delete" => "1", "id" => "i8tnddObffbIfNgylX7zSA==" },
                  "1" => { "name" => "hotel.pdf", "delete" => "0", "id" => "y5Fm8YK9-ekjEwUMKeeutw==" },
                  "2" => { "name" => "code4lib.pdf", "delete" => "0", "id" => "64Y9v5yGshHFgE6fS4FRew==" }
                }
              }
            end

            before do
              allow(subject).to receive(:valid?).and_return(true)
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
            end

            it 'will attach_or_update_files' do
              expect(subject.send(:attachments_extension)).to receive(:attach_or_update_files).with(requested_by: subject.requested_by)
              subject.submit
            end
          end

          context '#submit' do
            let(:user) { double('User') }
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit)
              end
              it 'will not create any attachments' do
                expect { subject.submit }.
                  to_not change { Models::Attachment.count }
              end
            end

            context 'with valid data' do
              let(:attributes) { { files: [file], remove_files: [remove_file] } }
              let(:file) { double('A File') }
              let(:remove_file) { double('File to delete') }

              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will attach each file' do
                expect(repository).to receive(:attach_files_to).and_call_original
                subject.submit
              end

              it 'will mark a file as representative' do
                expect(repository).to receive(:set_as_representative_attachment).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
