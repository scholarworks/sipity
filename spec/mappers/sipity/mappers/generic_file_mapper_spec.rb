require 'spec_helper'
require 'sipity/mappers/generic_file_mapper'

module Sipity
  module Mappers
    RSpec.describe GenericFileMapper do
      let(:access_right) { double(access_right_code: 'private_access') }
      let(:work) { double(id: 'work_id') }
      let(:file) do
        double(work: work,
               predicate_name: "attachment",
               pid: "a_pid",
               file_uid: "file_relative_path",
               file_name: "file_name",
               file_path: "file_path",
               created_at: Time.zone.today,
               updated_at: Time.zone.today)
      end
      let(:repository) { QueryRepositoryInterface.new }
      let(:creators) { [double(username: 'Hello')] }
      let(:batch_user) { 'curate_batch_user' }
      let(:sample_file) { File.new(__FILE__) }
      let(:fedora_date) { Time.zone.today.strftime('%FZ') }

      subject { described_class.new(file, repository: repository) }

      its(:default_repository) { should respond_to :attachment_access_right }
      its(:default_attribute_map) { should be_a(Hash) }
      its(:default_mount_data_path) { should be_a(String) }

      before do
        allow(file).to receive_message_chain("file.to_file") { sample_file }
        allow(file).to receive_message_chain("file.mime_type") { "a_mime_type" }
      end

      it 'will instantiate then call the instance' do
        expect(described_class).to receive(:new).and_return(double(call: true))
        described_class.call(work)
      end

      it 'verify if maps additional attributes, right and pid' do
        expect(repository).to receive(:scope_users_for_entity_and_roles).
          with(entity: work, roles: 'creating_user').and_return(creators)
        allow(repository).to receive(:attachment_access_right).with(attachment: file).and_return(access_right)
        expect(work).to receive(:id).and_return('a_work_id')
        expected_json = JSON.parse(subject.call)
        expect(expected_json["pid"]).to eq("und:a_pid")
        expect(expected_json["rights"]).to eq("read" => ['Hello'], "edit" => [batch_user])
        expect(expected_json["metadata"]["dc:title"]).to eq(file.file_name)
        expect(expected_json["metadata"]["dc:dateSubmitted"]).to eq(fedora_date)
        expect(expected_json["metadata"]["dc:modified"]).to eq(fedora_date)
      end

      it 'verify if dates are mapped to nil if not available in database' do
        expect(file).to receive(:created_at).and_return(nil)
        expect(file).to receive(:updated_at).and_return(nil)
        expect(repository).to receive(:scope_users_for_entity_and_roles).
          with(entity: work, roles: 'creating_user').and_return(creators)
        expect(repository).to receive(:attachment_access_right).with(attachment: file).and_return(access_right)
        expect(work).to receive(:id).and_return('a_work_id')
        expected_json = JSON.parse(subject.call)
        expect(expected_json["metadata"]["dc:dateSubmitted"]).to eq(nil)
        expect(expected_json["metadata"]["dc:modified"]).to eq(nil)
      end

      it 'verify rels-ext attributes' do
        expect(repository).to receive(:scope_users_for_entity_and_roles).
          with(entity: work, roles: 'creating_user').and_return(creators)
        allow(repository).to receive(:attachment_access_right).with(attachment: file).and_return(access_right)
        expect(work).to receive(:id).and_return('a_work_id')
        expected_json = JSON.parse(subject.call)
        expect(expected_json["rels-ext"]["@context"]).to eq("hydramata-rel" => "http://projecthydra.org/ns/relations#")
        expect(expected_json["rels-ext"]["isPartOf"]).to eq(["und:a_work_id"])
        expect(expected_json["rels-ext"]["hydramata-rel:hasEditor"]).to eq(['batch_user_pid'])
        expect(expected_json["rels-ext"]["hydramata-rel:hasEditorGroup"]).to eq(['batch_group_pid'])
      end

      it 'verify content datastream attributes' do
        expect(repository).to receive(:scope_users_for_entity_and_roles).
          with(entity: work, roles: 'creating_user').and_return(creators)
        expect(repository).to receive(:attachment_access_right).with(attachment: file).and_return(access_right)
        expect(work).to receive(:id).and_return('a_work_id')
        expect(subject).to receive(:file_name_to_create).and_return(File.basename(__FILE__))
        expected_json = JSON.parse(subject.call)
        expect(expected_json["content-meta"]).to eq("mime-type" => file.file.mime_type, "label" => file.file_name)
        expect(expected_json["content-file"]).to eq(File.basename(__FILE__))
      end

      context 'will have be able to map correct access_right' do
        it 'have public access rights' do
          access_right = double(access_right_code: 'open_access')
          expect(repository).to receive(:scope_users_for_entity_and_roles).
            with(entity: work, roles: 'creating_user').and_return(creators)
          expect(repository).to receive(:attachment_access_right).with(attachment: file).and_return(access_right)
          expect(work).to receive(:id).and_return('a_work_id')
          expected_json = JSON.parse(subject.call)
          expect(expected_json["rights"]).to eq("read-groups" => ["public"], "read" => ['Hello'], "edit" => [batch_user])
        end

        it 'have work access_right when file have no access rights ' do
          access_right = double(access_right_code: 'open_access')
          expect(repository).to receive(:scope_users_for_entity_and_roles).
            with(entity: work, roles: 'creating_user').and_return(creators)
          expect(repository).to receive(:attachment_access_right).with(attachment: file).and_return(access_right)
          expect(work).to receive(:id).and_return('a_work_id')
          expected_json = JSON.parse(subject.call)
          expect(expected_json["rights"]).to eq("read-groups" => ["public"], "read" => ['Hello'], "edit" => [batch_user])
        end

        it 'will use attachment access_right when available' do
          access_right = double(access_right_code: 'restricted_access')
          expect(repository).to receive(:scope_users_for_entity_and_roles).
            with(entity: work, roles: 'creating_user').and_return(creators)
          expect(repository).to receive(:attachment_access_right).with(attachment: file).and_return(access_right)
          expect(work).to receive(:id).and_return('a_work_id')
          expected_json = JSON.parse(subject.call)
          expect(expected_json["rights"]).to eq("read-groups" => ["restricted"], "read" => ['Hello'], "edit" => [batch_user])
        end

        context 'will add embargo date to rights metadata' do
          let(:embargo_date) { "2022-12-01" }
          let(:access_right) do
            Models::AccessRight.new(
              access_right_code: 'embargo_then_open_access', release_date: Time.zone.today, transition_date: embargo_date
            )
          end
          it 'return embargo date from work when attachment access right is empty' do
            expect(work).to receive(:id).and_return('a_id')
            expect(repository).to receive(:scope_users_for_entity_and_roles).
              with(entity: work, roles: 'creating_user').and_return(creators)
            allow(repository).to receive(:attachment_access_right).with(attachment: file).and_return(access_right)
            expected_json = JSON.parse(subject.call)
            expect(expected_json["rights"]).to eq("embargo-date" => embargo_date, "read-groups" => ["public"],
                                                  "read" => ['Hello'], "edit" => [batch_user])
          end
          it 'have public access rights with embargo date' do
            allow(repository).to receive(:attachment_access_right).with(attachment: file).and_return(access_right)
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
