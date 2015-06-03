require 'spec_helper'

module Sipity
  module Mappers
    RSpec.describe GenericFileMapper do
      let(:access_right) { ['private_access'] }
      let(:work) { double }
      let(:file) do
        double(work: work,
               predicate_name: "attachment",
               pid: "a_pid",
               file: double(mime_type: "a_mime_type"),
               file_uid: "file_relative_path",
               file_name: "file_name",
               file_path: "file_path",
               created_at: Time.zone.today,
               updated_at: Time.zone.today)
      end
      let(:repository) { QueryRepositoryInterface.new }
      let(:creators) { [double(username: 'Hello')] }
      let(:batch_user) { 'curate_batch_user' }
      let(:batch_user_pid) { 'und:4j03cz30t6k' }
      let(:batch_group_pid) { 'und:p2676t05p31' }

      subject { described_class.new(file, repository: repository) }

      its(:default_repository) { should respond_to :attachment_access_right_codes }

      it 'will instantiate then call the instance' do
        expect(described_class).to receive(:new).and_return(double(call: true))
        described_class.call(work)
      end

      it 'verify if maps additional attributes, right and pid' do
        expect(repository).to receive(:scope_users_for_entity_and_roles).
          with(entity: work, roles: 'creating_user').and_return(creators)
        expect(repository).to receive(:attachment_access_right_codes).with(attachment: file).and_return([])
        expect(repository).to receive(:work_access_right_codes).with(work: work).and_return(access_right)
        expect(work).to receive(:id).and_return('a_work_id')
        expected_json = JSON.parse(subject.call)
        expect(expected_json["pid"]).to eq("und:a_pid")
        expect(expected_json["rights"]).to eq("read" => ['Hello'], "edit" => [batch_user])
        expect(expected_json["metadata"]["dc:title"]).to eq(file.file_name)
      end

      it 'verify rels-ext attributes' do
        expect(repository).to receive(:scope_users_for_entity_and_roles).
          with(entity: work, roles: 'creating_user').and_return(creators)
        expect(repository).to receive(:attachment_access_right_codes).with(attachment: file).and_return([])
        expect(repository).to receive(:work_access_right_codes).with(work: work).and_return(access_right)
        expect(work).to receive(:id).and_return('a_work_id')
        expected_json = JSON.parse(subject.call)
        expect(expected_json["rels-ext"]["@context"]).to eq("hydramata-rel" =>  "http://projecthydra.org/ns/relations#")
        expect(expected_json["rels-ext"]["isPartOf"]).to eq(["und:a_work_id"])
        expect(expected_json["rels-ext"]["hydramata-rel:hasEditor"]).to eq([batch_user_pid])
        expect(expected_json["rels-ext"]["hydramata-rel:hasEditorGroup"]).to eq([batch_group_pid])
      end

      it 'verify content datastream attributes' do
        expect(repository).to receive(:scope_users_for_entity_and_roles).
          with(entity: work, roles: 'creating_user').and_return(creators)
        expect(repository).to receive(:attachment_access_right_codes).with(attachment: file).and_return([])
        expect(repository).to receive(:work_access_right_codes).with(work: work).and_return(access_right)
        expect(work).to receive(:id).and_return('a_work_id')
        expected_json = JSON.parse(subject.call)
        expect(expected_json["content-meta"]).to eq("mime-type" => file.file.mime_type, "label" => file.file_name)
        expect(expected_json["content-file"]).to eq(file.file_path)
      end

      context 'will have be able to map correct access_right' do
        it 'have public access rights' do
          access_right = ['open_access']
          expect(repository).to receive(:scope_users_for_entity_and_roles).
            with(entity: work, roles: 'creating_user').and_return(creators)
          expect(repository).to receive(:attachment_access_right_codes).with(attachment: file).and_return(access_right)
          expect(work).to receive(:id).and_return('a_work_id')
          expected_json = JSON.parse(subject.call)
          expect(expected_json["rights"]).to eq("read-groups" => ["public"], "read" => ['Hello'], "edit" => [batch_user])
        end

        it 'have work access_right when file have no access rights ' do
          expect(repository).to receive(:scope_users_for_entity_and_roles).
            with(entity: work, roles: 'creating_user').and_return(creators)
          expect(repository).to receive(:attachment_access_right_codes).with(attachment: file).and_return([])
          expect(repository).to receive(:work_access_right_codes).with(work: work).and_return(['open_access'])
          expect(work).to receive(:id).and_return('a_work_id')
          expected_json = JSON.parse(subject.call)
          expect(expected_json["rights"]).to eq("read-groups" => ["public"], "read" => ['Hello'], "edit" => [batch_user])
        end

        it 'will use attachment access_right when available' do
          expect(repository).to receive(:scope_users_for_entity_and_roles).
            with(entity: work, roles: 'creating_user').and_return(creators)
          expect(repository).to receive(:attachment_access_right_codes).with(attachment: file).and_return(["restricted_access"])
          allow(repository).to receive(:work_access_right_codes).and_return(["open_access"])
          expect(work).to receive(:id).and_return('a_work_id')
          expected_json = JSON.parse(subject.call)
          expect(expected_json["rights"]).to eq("read-groups" => ["restricted"], "read" => ['Hello'], "edit" => [batch_user])
        end

        context 'will add embargo date to rights metadata' do
          let(:embargo_date) { "2022-12-01" }
          it 'return embargo date from attachment' do
            access_rights = Models::AccessRight.new(access_right_code: 'embargo_then_open_access',
                                                    release_date: Time.zone.today, transition_date: embargo_date)
            expect(work).to receive(:id).and_return('a_id')
            expect(repository).to receive(:scope_users_for_entity_and_roles).
              with(entity: work, roles: 'creating_user').and_return(creators)
            expect(repository).to receive(:attachment_access_right_codes).with(attachment: file).
              and_return([access_rights.access_right_code])
            expect(file).to receive(:access_rights).and_return([access_rights])
            expected_json = JSON.parse(subject.call)
            expect(expected_json["rights"]).to eq("embargo-date" => embargo_date, "read-groups" => ["public"],
                                                  "read" => ['Hello'], "edit" => [batch_user])
          end

          it 'return embargo date from work when attachment access right is empty' do
            access_rights = Models::AccessRight.new(access_right_code: 'embargo_then_open_access',
                                                    release_date: Time.zone.today, transition_date: embargo_date)
            expect(work).to receive(:id).and_return('a_id')
            expect(repository).to receive(:scope_users_for_entity_and_roles).
              with(entity: work, roles: 'creating_user').and_return(creators)
            expect(repository).to receive(:attachment_access_right_codes).with(attachment: file).and_return([])
            expect(repository).to receive(:work_access_right_codes).with(work: work).and_return([access_rights.access_right_code])
            expect(work).to receive(:access_rights).and_return([access_rights])
            expected_json = JSON.parse(subject.call)
            expect(expected_json["rights"]).to eq("embargo-date" => embargo_date, "read-groups" => ["public"],
                                                  "read" => ['Hello'], "edit" => [batch_user])
          end
          it 'have public access rights with embargo date' do
            access_right = ['embargo_then_open_access']
            expect(repository).to receive(:attachment_access_right_codes).with(attachment: file).and_return([])
            expect(repository).to receive(:work_access_right_codes).with(work: work).and_return(access_right)
            expect(subject).to receive(:embargo_date).and_return([embargo_date])
            expect(repository).to receive(:scope_users_for_entity_and_roles).
              with(entity: work, roles: 'creating_user').and_return(creators)
            expect(work).to receive(:id).and_return('a_id')
            expected_json = JSON.parse(subject.call)
            expect(expected_json["rights"]).to eq("embargo-date" => [embargo_date], "read-groups" => ["public"],
                                                  "read" => ['Hello'], "edit" => [batch_user])
          end
        end
      end
    end
  end
end
