require 'spec_helper'

module Sipity
  module Forms
    module ComposableElements
      RSpec.describe AttachmentsExtension do

        let(:work) { Models::Work.new(id: '1234') }
        let(:repository) { CommandRepositoryInterface.new }
        let(:user) { double('User') }
        let(:attachments_attributes) do
          {
            "0" => { "name" => "code4lib.pdf", "delete" => "1", "id" => "i8tnddObffbIfNgylX7zSA==" },
            "1" => { "name" => "hotel.pdf", "delete" => "0", "id" => "y5Fm8YK9-ekjEwUMKeeutw==" },
            "2" => { "name" => "code4lib.pdf", "delete" => "0", "id" => "64Y9v5yGshHFgE6fS4FRew==" }
          }
        end
        let(:form) { double('Form', work: work) }
        subject do
          described_class.new(
            repository: repository,
            form: form,
            files: {},
            attachments_attributes: attachments_attributes
          )
        end

        it { should respond_to :repository }
        it { should respond_to :files }
        it { should respond_to :attach_or_update_files }
        it { should respond_to :attachments_attributes= }
        it { should respond_to :attachments }

        it 'will call attachments_from_work' do
          expect(repository).to receive(:work_attachments).with(work: work).and_return([double, double])
          subject.attachments
        end

        context 'attach_or_update_files' do
          let(:attachments_attributes) do
            {
              "0" => { "name" => "code4lib.pdf", "delete" => "1", "id" => "i8tnddObffbIfNgylX7zSA==" },
              "1" => { "name" => "hotel.pdf", "delete" => "0", "id" => "y5Fm8YK9-ekjEwUMKeeutw==" },
              "2" => { "name" => "code4lib.pdf", "delete" => "0", "id" => "64Y9v5yGshHFgE6fS4FRew==" },
              "3" => { "name" => "conference.pdf", "delete" => "0", "id" => "77Z8v5yGshHFgE6fS4FRew==" }
            }
          end

          it 'will update attachments' do
            subject.attachments_attributes = attachments_attributes
            expect(repository).to receive(:amend_files_metadata).
              with(
                work: work, user: user, metadata: {
                  "y5Fm8YK9-ekjEwUMKeeutw==" => { "name" => "hotel.pdf" },
                  "64Y9v5yGshHFgE6fS4FRew==" => { "name" => "code4lib.pdf" },
                  "77Z8v5yGshHFgE6fS4FRew==" => { "name" => "conference.pdf" }
                }
              )
            subject.attach_or_update_files(requested_by: user)
          end
        end
      end
    end
  end
end
