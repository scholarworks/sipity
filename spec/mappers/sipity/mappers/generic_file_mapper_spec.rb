require 'spec_helper'

module Sipity
  module Mappers
    RSpec.describe GenericFileMapper do
      let(:access_right) { ['private_access'] }
      let(:work) { double }
      let(:file) { double( work: work,
                          predicate_name: "attachment",
                          pid: "a_pid",
                          file: double(mime_type: "a_mime_type"),
                          file_uid: "file_relative_patj",
                          file_name: "file_name",
                          created_at: Time.zone.today,
                          updated_at: Time.zone.today)
                }
      let(:repository) { QueryRepositoryInterface.new }
      let(:creators) { [double(username: 'Hello')] }

      subject { described_class.new(file, repository: repository) }

      its(:default_repository) { should respond_to :attachment_access_right_codes }

      it 'will instantiate then call the instance' do
        expect(described_class).to receive(:new).and_return(double(call: true))
        described_class.call(work)
      end

      it 'will map additional attributes, right and pid' do
        expect(repository).to receive(:scope_users_for_entity_and_roles).
          with(entity: work, roles: 'creating_user').and_return(creators)
        expect(repository).to receive(:attachment_access_right_codes).with(attachment: file).and_return([])
        expect(repository).to receive(:work_access_right_codes).with(work: work).and_return(access_right)
        expect(work).to receive(:id).and_return('a_work_id')
        expected_json = JSON.parse(subject.call)
        expect(expected_json["pid"]).to eq("und:a_pid")
        expect(expected_json["rights"]).to eq([{"read" => [['Hello']]}])
        expect(expected_json["metadata"]["dc:title"]).to eq(file.file_name)
      end

      context 'will have be able to map correct access_right' do
        it 'have public access rights' do
          access_right = ['open_access']
          expect(repository).to receive(:scope_users_for_entity_and_roles).
            with(entity: work, roles: 'creating_user').and_return(creators)
          expect(repository).to receive(:attachment_access_right_codes).with(attachment: file).and_return(access_right)
          expect(work).to receive(:id).and_return('a_work_id')
          expected_json = JSON.parse(subject.call)
          expect(expected_json["rights"]).to eq([{"read-groups"=> ["public"], "read" => [['Hello']]}])
        end

        it 'have work access_right when file have no access rights ' do
          expect(repository).to receive(:scope_users_for_entity_and_roles).
            with(entity: work, roles: 'creating_user').and_return(creators)
          expect(repository).to receive(:attachment_access_right_codes).with(attachment: file).and_return([])
          expect(repository).to receive(:work_access_right_codes).with(work: work).and_return(['open_access'])
          expect(work).to receive(:id).and_return('a_work_id')
          expected_json = JSON.parse(subject.call)
          expect(expected_json["rights"]).to eq([{"read-groups"=> ["public"], "read" => [['Hello']]}])
        end

        it 'will use attachment access_right when available' do
          expect(repository).to receive(:scope_users_for_entity_and_roles).
            with(entity: work, roles: 'creating_user').and_return(creators)
          expect(repository).to receive(:attachment_access_right_codes).with(attachment: file).and_return(["restricted_access"])
          allow(repository).to receive(:work_access_right_codes).and_return(["open_access"])
          expect(work).to receive(:id).and_return('a_work_id')
          expected_json = JSON.parse(subject.call)
          expect(expected_json["rights"]).to eq([{"read-groups"=> ["restricted"], "read" => [['Hello']]}])
        end

        context 'will add embargo date to rights metadata' do
          let(:embargo_date) { "2022-12-01" }
          it 'have public access rights with embargo date' do
            access_right = ['embargo_then_open_access']
            expect(repository).to receive(:attachment_access_right_codes).with(attachment: file).and_return([])
            expect(repository).to receive(:work_access_right_codes).with(work: work).and_return(access_right)
            expect(subject).to receive(:embargo_date).and_return([embargo_date])
            expect(repository).to receive(:scope_users_for_entity_and_roles).
             with(entity: work, roles: 'creating_user').and_return(creators)
            expect(work).to receive(:id).and_return('a_id')
            expected_json = JSON.parse(subject.call)
            expect(expected_json["rights"]).to eq([{"embargo-date"=> [embargo_date], "read" => [['Hello']]}])
          end
        end
        xit 'Embargo test'
        xit 'rels-ext verification'
        xit 'content filename and file path'
      end
    end
  end
end
