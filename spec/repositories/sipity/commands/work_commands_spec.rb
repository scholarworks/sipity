require 'rails_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/commands/work_commands'

module Sipity
  module Commands
    RSpec.describe WorkCommands, type: :command_with_related_query do
      before do
        # TODO: Remove this once the deprecation for granting permission is done
        allow(Services::GrantProcessingPermission).to receive(:call)
      end

      context '#destroy_a_work' do
        let(:work) { Models::Work.new(id: '1') }
        it 'will destroy the work in question' do
          work.save! # so it is persisted
          expect { test_repository.destroy_a_work(work: work) }.
            to change { Models::Work.count }.by(-1)
          expect { work.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context '#change_processing_actor_proxy' do
        let(:user) { User.create!(username: 'hello') }
        let(:collaborator) { Models::Collaborator.create!(name: 'bob', role: 'Committee Member', work_id: 1) }
        let(:current_actor) { collaborator.to_processing_actor }
        it 'will transfer ownership from the given proxy to another' do
          expect { test_repository.change_processing_actor_proxy(from_proxy: collaborator, to_proxy: user) }.
            to change { current_actor.reload.proxy_for }.from(collaborator).to(user)
        end
      end

      context '#manage_collaborators_for' do
        let(:work) { Models::Work.new(id: 123) }
        let(:collaborator) do
          Models::Collaborator.new(
            work_id: work.id, responsible_for_review: true, name: 'Jeremy', role: 'Research Director', netid: 'somebody'
          )
        end
        it 'will destroy collaborators not passed in' do
          collaborator.save!
          expect(test_repository).to receive(:assign_collaborators_to).with(work: work, collaborators: [], repository: test_repository)
          expect { test_repository.manage_collaborators_for(work: work, collaborators: []) }.
            to change { Models::Collaborator.count }.by(-1)
        end

        it 'will destroy the collaborator processing actor' do
          collaborator.save!
          collaborator.to_processing_actor
          expect(test_repository).to receive(:assign_collaborators_to).with(work: work, collaborators: [], repository: test_repository)
          expect { test_repository.manage_collaborators_for(work: work, collaborators: []) }.
            to change { Models::Processing::Actor.count }.by(-1)
        end
      end

      context '#assign_collaborators_to' do
        let(:work) { Models::Work.new(id: 123) }
        let(:repository) { CommandRepositoryInterface.new }
        let(:collaborator) do
          Models::Collaborator.new(
            responsible_for_review: is_responsible_for_review?, name: 'Jeremy', role: 'Research Director', netid: 'somebody'
          )
        end
        context 'when a collaborator is responsible_for_review' do
          let(:is_responsible_for_review?) { false }
          it 'will create a collaborator but not a user nor permission' do
            expect do
              expect do
                test_repository.assign_collaborators_to(work: work, collaborators: collaborator, repository: repository)
              end.to change(Models::Collaborator, :count).by(1)
            end.to_not change(User, :count)
          end
        end

        context 'when a collaborator is responsible_for_review' do
          let(:is_responsible_for_review?) { true }
          it 'will create a collaborator, user, and permission' do
            expect(repository).to receive(:grant_permission_for!).and_call_original
            expect do
              expect do
                test_repository.assign_collaborators_to(work: work, collaborators: collaborator, repository: repository)
              end.to change(Models::Collaborator, :count).by(1)
            end.to change(User, :count).by(1)
          end
        end
      end

      context '#create_work!' do
        let(:attributes) { { title: 'Hello', work_publication_strategy: 'do_not_know', work_type: 'doctoral_dissertation' } }
        it 'will delegate to the Services::CreateWorkService' do
          submission_window = double
          expect(Services::CreateWorkService).to receive(:call).
            with(submission_window: submission_window, repository: test_repository, **attributes)
          test_repository.create_work!(submission_window: submission_window, **attributes)
        end
      end

      context '#update_title!' do
        it 'will update title of the work object' do
          work = Models::Work.create!(id: '12', title: 'bogus')
          expect { test_repository.update_work_title!(work: work, title: 'helloworld') }.
            to change(work, :title).from('bogus').to('helloworld')
        end
      end

      context '#default_pid_minter' do
        subject { test_repository.default_pid_minter }
        it { is_expected.to respond_to(:call) }
        its(:call) { is_expected.to be_a(String) }
      end

      context '#create_sipity_user_from' do
        it 'will create a user from the given netid if one does not exist' do
          expect { test_repository.create_sipity_user_from(netid: 'helloworld') }.
            to change { User.count }.by(1)
          expect(User.last.email).to be_present
        end
        it 'will not create multiple times' do
          user = Factories.create_user
          expect { test_repository.create_sipity_user_from(netid: user.username) }.
            to_not change { User.count }
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
        let(:work) { Models::Work.create!(id: '1') }
        it 'will update update the entity processing state' do
          expect(Services::UpdateEntityProcessingState).to receive(:call)
          test_repository.update_processing_state!(entity: work, to: 'hello')
        end
      end

      context '#attach_files_to' do
        let(:file) { FileUpload.fixture_file_upload('attachments/hello-world.txt') }
        let(:user) { User.new(id: 1234) }
        let(:work) { Models::Work.create!(id: '1') }
        let(:pid_minter) { -> { 'abc123' } }
        it 'will increment the number of attachments in the system' do
          expect { test_repository.attach_files_to(work: work, files: file, user: user, pid_minter: pid_minter) }.
            to change { Models::Attachment.where(pid: 'abc123').count }.by(1)
        end

        it 'will not increment the number of attachments in the system if we get an empty hash' do
          expect { test_repository.attach_files_to(work: work, files: {}, user: user, pid_minter: pid_minter) }.
            to_not change { Models::Attachment.where(pid: 'abc123').count }
        end
      end

      context '#remove_files_form' do
        let(:file) { FileUpload.fixture_file_upload('attachments/hello-world.txt') }
        let(:file_name) { "hello-world.txt" }
        let(:user) { User.new(id: 1234) }
        let(:work) { Models::Work.create!(id: '1') }
        let(:pid_minter) { -> { 'abc123' } }
        before { test_repository.attach_files_to(work: work, files: file, user: user, pid_minter: pid_minter) }
        it 'will decrease the number of attachments in the system' do
          expect { test_repository.remove_files_from(pids: pid_minter.call, work: work, user: user) }.
            to change { Models::Attachment.count }.by(-1)
        end

        it 'will only destroy attachments of the specified predicate' do
          expect { test_repository.remove_files_from(pids: pid_minter.call, work: work, user: user, predicate_name: 'other') }.
            to_not change { Models::Attachment.count }
        end
      end

      context '#amend_files_metadata' do
        let(:file) { FileUpload.fixture_file_upload('attachments/hello-world.txt') }
        let(:file_name) { "hello-world.txt" }
        let(:user) { User.new(id: 1234) }
        let(:work) { Models::Work.create!(id: 1) }
        let(:pid_minter) { -> { 'abc123' } }
        before { test_repository.attach_files_to(work: work, files: file, user: user, pid_minter: pid_minter) }
        it 'will change the file name' do
          test_repository.amend_files_metadata(work: work, user: user, metadata: { 'abc123' => { 'name' => 'Howdy' } })
          expect(Models::Attachment.find('abc123').name).to eq('Howdy')
        end
      end

      context '#set_as_representative_attachment' do
        let(:file) { FileUpload.fixture_file_upload('attachments/hello-world.txt') }
        let(:file_name) { "hello-world.txt" }
        let(:user) { User.new(id: 1234) }
        let(:work) { Models::Work.create!(id: '1') }
        let(:pid_minter) { -> { 'abc123' } }
        before { test_repository.attach_files_to(work: work, files: file, user: user, pid_minter: pid_minter) }
        it 'will mark the given attachments as representative in the system' do
          expect { test_repository.set_as_representative_attachment(work: work, pid: pid_minter.call) }.
            to change { Models::Attachment.where(is_representative_file: true).count }.by(1)
        end
        it 'will not mark the given attachments as representative in the system' do
          expect { test_repository.set_as_representative_attachment(work: work, pid: 'bogus') }.
            not_to change { Models::Attachment.where(is_representative_file: true).count }
        end
      end

      context '#apply_access_policies_to' do
        let(:work) { double('Work') }
        let(:user) { double('User') }
        let(:access_policies) { double('AccessPolicies') }
        it 'will mark the given attachments as representative in the system' do
          expect(Services::ApplyAccessPoliciesTo).to receive(:call).with(work: work, user: user, access_policies: access_policies)
          test_repository.apply_access_policies_to(work: work, user: user, access_policies: access_policies)
        end
      end
    end
  end
end
