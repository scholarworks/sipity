require 'spec_helper'

module Sipity
  module Forms
    module WorkEnrichments
      RSpec.describe AttachForm do
        let(:work) { Models::Work.new(id: '1234') }
        subject { described_class.new(work: work) }

        its(:policy_enforcer) { should be_present }
        its(:enrichment_type) { should eq('attach') }

        it { should respond_to :attachments }

        context 'validations' do
          it 'will require a work' do
            subject = described_class.new(work: nil)
            subject.valid?
            expect(subject.errors[:work]).to_not be_empty
          end

          let(:representative_for_attachment) { [double('Attachment')] }
          it 'will have #representative_for_attachment_id' do
            allow(Queries::AttachmentQueries).to receive(:representative_attachment_for).
              with(work: work).and_return(representative_for_attachment)
            subject.representative_attachment
          end

          let(:attachment) { [double('Attachment')] }
          it 'will have #attachments' do
            allow(work).to receive(:attachments).and_return(attachment)
            expect(subject.attachments).to_not be_empty
          end
        end

        context 'assigning attachments attributes' do
          let(:user) { double('User') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attachments_attributes) do
            {
              "0" => { "name" => "code4lib.pdf", "delete" => "1", "id" => "i8tnddObffbIfNgylX7zSA==" },
              "1" => { "name" => "hotel.pdf", "delete" => "0", "id" => "y5Fm8YK9-ekjEwUMKeeutw==" },
              "2" => { "name" => "code4lib.pdf", "delete" => "0", "id" => "64Y9v5yGshHFgE6fS4FRew==" }
            }
          end
          subject { described_class.new(work: work, repository: repository, attachments_attributes: attachments_attributes) }

          before do
            allow(subject).to receive(:valid?).and_return(true)
          end

          it 'will delete any attachments marked for deletion' do
            expect(repository).to receive(:remove_files_from).with(work: work, user: user, pids: ["i8tnddObffbIfNgylX7zSA=="])
            subject.submit(repository: repository, requested_by: user)
          end
        end

        context '#submit' do
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          context 'with invalid data' do
            before do
              expect(subject).to receive(:valid?).and_return(false)
            end
            it 'will return false if not valid' do
              expect(subject.submit(repository: repository, requested_by: user))
            end
            it 'will not create any attachments' do
              expect { subject.submit(repository: repository, requested_by: user) }.
                to_not change { Models::Attachment.count }
            end
          end

          context 'with valid data' do
            subject { described_class.new(work: work, files: [file], remove_files: [remove_file])  }
            let(:file) { double('A File') }
            let(:remove_file) { double('File to delete') }

            before do
              expect(subject).to receive(:valid?).and_return(true)
            end

            it 'will return the work' do
              returned_value = subject.submit(repository: repository, requested_by: user)
              expect(returned_value).to eq(work)
            end

            it 'will attach each file' do
              expect(repository).to receive(:attach_file_to).and_call_original
              subject.submit(repository: repository, requested_by: user)
            end

            it "will transition the work's corresponding enrichment todo item to :done" do
              expect(repository).to receive(:register_action_taken_on_entity).and_call_original
              subject.submit(repository: repository, requested_by: user)
            end

            it 'will record the event' do
              expect(repository).to receive(:log_event!).and_call_original
              subject.submit(repository: repository, requested_by: user)
            end

            it 'will mark a file as representative' do
              expect(repository).to receive(:mark_as_representative).and_call_original
              subject.submit(repository: repository, requested_by: user)
            end
          end
        end
      end
    end
  end
end
