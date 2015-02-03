require 'rails_helper'

module Sipity
  module Commands
    RSpec.describe WorkCommands, type: :command_with_related_query do

      context '#assign_collaborators_to' do
        let(:work) { Models::Work.new(id: 123) }
        let(:collaborator) { Models::Collaborator.new(name: 'Jeremy', role: 'advisor') }
        it 'will create an collaborator' do
          expect(test_repository).to receive(:create_sipity_user_from).with(netid: collaborator.netid)
          expect { test_repository.assign_collaborators_to(work: work, collaborators: collaborator) }.
            to change { Models::Collaborator.where(work_id: work.id).count }.by(1)
        end
      end

      context '#create_sipity_user_from' do
        it 'will create a user from the given netid if one does not exist' do
          expect { test_repository.create_sipity_user_from(netid: 'helloworld') }.
            to change { User.count }.by(1)
        end
        it 'will skip user creation of the netID exists' do
          test_repository.create_sipity_user_from(netid: 'helloworld')

          expect { test_repository.create_sipity_user_from(netid: 'helloworld') }.
            to_not change { User.count }
        end

        it 'will skip user creation if no netid is given' do
          expect { test_repository.create_sipity_user_from(netid: '') }.
            to_not change { User.count }
        end
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
