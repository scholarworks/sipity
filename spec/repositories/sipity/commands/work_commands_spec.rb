require 'rails_helper'

module Sipity
  module Commands
    RSpec.describe WorkCommands, type: :command_repository do
      context '#assign_a_pid' do
        it 'will assign a unique permanent persisted identifier for the work'
      end

      context '#update_processing_state!' do
        let(:work) { Models::Work.create! }
        it 'will update the underlying state of the object' do
          expect { test_repository.update_processing_state!(entity: work, to: 'hello') }.
            to change { work.processing_state }.to('hello')
        end
      end

      context '#attach_file_to' do
        let(:file) { FileUpload.fixture_file_upload('attachments/hello-world.txt') }
        let(:user) { User.new(id: 1234) }
        let(:work) { Models::Work.create! }
        let(:pid_minter) { -> { 'abc123' } }
        it 'will increment the number of attachments in the system' do
          expect { test_repository.attach_file_to(work: work, file: file, user: user, pid_minter: pid_minter) }.
            to change { Models::Attachment.count }.by(1)
        end
      end
    end
  end
end
