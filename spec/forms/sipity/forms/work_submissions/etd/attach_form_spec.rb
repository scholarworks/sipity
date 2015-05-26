require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe AttachForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          subject { described_class.new(work: work, repository: repository) }

          its(:policy_enforcer) { should be_present }
          its(:enrichment_type) { should eq('attach') }

          it { should respond_to :attachments }
          it { should respond_to :representative_attachment_id }
          it { should respond_to :files }

          context 'validations' do
            it 'will require a work' do
              subject = described_class.new(work: nil, repository: repository)
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
            let(:attachments_attributes) do
              {
                "0" => { "name" => "code4lib.pdf", "delete" => "1", "id" => "i8tnddObffbIfNgylX7zSA==" },
                "1" => { "name" => "hotel.pdf", "delete" => "0", "id" => "y5Fm8YK9-ekjEwUMKeeutw==" },
                "2" => { "name" => "code4lib.pdf", "delete" => "0", "id" => "64Y9v5yGshHFgE6fS4FRew==" }
              }
            end
            subject do
              described_class.new(work: work, repository: repository, attributes: { attachments_attributes: attachments_attributes })
            end

            before do
              allow(subject).to receive(:valid?).and_return(true)
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
            end

            it 'will delete any attachments marked for deletion' do
              expect(repository).to receive(:remove_files_from).with(work: work, user: user, pids: ["i8tnddObffbIfNgylX7zSA=="])
              subject.submit(requested_by: user)
            end

            it 'will amend any attachment metadata' do
              expect(repository).to receive(:amend_files_metadata).with(
                work: work, user: user, metadata: {
                  "y5Fm8YK9-ekjEwUMKeeutw==" => { "name" => "hotel.pdf" },
                  "64Y9v5yGshHFgE6fS4FRew==" => { "name" => "code4lib.pdf" }
                }
              )
              subject.submit(requested_by: user)
            end
          end

          context '#submit' do
            let(:user) { double('User') }
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit(requested_by: user))
              end
              it 'will not create any attachments' do
                expect { subject.submit(requested_by: user) }.
                  to_not change { Models::Attachment.count }
              end
            end

            context 'with valid data' do
              subject do
                described_class.new(work: work, repository: repository, attributes: { files: [file], remove_files: [remove_file] })
              end

              let(:file) { double('A File') }
              let(:remove_file) { double('File to delete') }

              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will attach each file' do
                expect(repository).to receive(:attach_files_to).and_call_original
                subject.submit(requested_by: user)
              end

              it "will unregister that the 'access_policy' action was taken" do
                expect(repository).to receive(:unregister_action_taken_on_entity).and_call_original
                subject.submit(requested_by: user)
              end

              it 'will mark a file as representative' do
                expect(repository).to receive(:set_as_representative_attachment).and_call_original
                subject.submit(requested_by: user)
              end
            end
          end
        end
      end
    end
  end
end
