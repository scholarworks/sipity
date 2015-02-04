require 'rails_helper'

module Sipity
  module Commands
    RSpec.describe WorkCommands, type: :command_with_related_query do

      context '#assign_collaborators_to' do
        let(:work) { Models::Work.new(id: 123) }
        let(:collaborator) do
          Models::Collaborator.new(responsible_for_review: is_responsible_for_review?, name: 'Jeremy', role: 'advisor', netid: 'somebody')
        end
        context 'when a collaborator is responsible_for_review' do
          let(:is_responsible_for_review?) { false }
          it 'will create a collaborator but not a user nor permission' do
            expect do
              expect do
                expect do
                  test_repository.assign_collaborators_to(work: work, collaborators: collaborator)
                end.to change(Models::Collaborator, :count).by(1)
              end.to_not change(Models::Permission, :count)
            end.to_not change(User, :count)
          end
        end

        context 'when a collaborator is responsible_for_review' do
          let(:is_responsible_for_review?) { true }
          it 'will create a collaborator, user, and permission' do
            expect do
              expect do
                expect do
                  test_repository.assign_collaborators_to(work: work, collaborators: collaborator)
                end.to change(Models::Collaborator, :count).by(1)
              end.to change(Models::Permission, :count).by(1)
            end.to change(User, :count).by(1)
          end
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
