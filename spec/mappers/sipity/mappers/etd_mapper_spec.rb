require 'spec_helper'

module Sipity
  module Mappers
    RSpec.describe EtdMapper do
      let(:access_right) { ['private_access'] }
      let(:work) { double }
      let(:repository) { QueryRepositoryInterface.new }
      let(:creators) { [double(username: 'Hello')] }
      let(:collaborators) { [double(name: 'Hello', role:'role')] }
      let(:contributor_map) { {'dc:contributor' => 'Hello', 'ms:role' =>'role'} }
      let(:degree_map) { {"ms:name"=>["a degree_name"], "ms:discipline"=>["a program_name"]} }
      let(:title) { 'Title of the work' }
      let(:batch_user) { 'curate_batch_user' }

      subject { described_class.new(work, repository: repository) }

      its(:default_repository) { should respond_to :work_attribute_key_value_pairs }

      it 'will instantiate then call the instance' do
        expect(described_class).to receive(:new).and_return(double(call: true))
        described_class.call(work)
      end

      it 'will map additional attributes, right and pid' do
        expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'language').and_return(['eng'])
        expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'alternate_title').and_return([])
        expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'subject').and_return([])
        expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'abstract').and_return([])
        expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'copyright').and_return([])
        expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'degree').and_return(['a degree_name'])
        expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'defense_date').and_return([])
        expect(repository).to receive(:work_attribute_values_for).with(work: work, key: 'program_name').and_return(['a program_name'])
        expect(repository).to receive(:work_access_right_codes).with(work: work).and_return(access_right)
        expect(repository).to receive(:scope_users_for_entity_and_roles).
          with(entity: work, roles: 'creating_user').and_return(creators)
        expect(work).to receive(:id).and_return('a_id')
        expect(work).to receive(:title).and_return(title)
        expect(work).to receive(:collaborators).and_return(collaborators)
        expected_json = JSON.parse(subject.call)
        puts "Json: #{expected_json.inspect}"
        expect(expected_json["pid"]).to eq("und:a_id")
        expect(expected_json["pid"]).to eq("und:a_id")
        expect(expected_json["rights"]).to eq("read" => ['Hello'], "edit" => [batch_user])
        expect(expected_json["metadata"]["dc:title"]).to eq(title)
        expect(expected_json["metadata"]["dc:language"]).to eq(['eng'])
        expect(expected_json["metadata"]["dc:contributor"]).to eq([contributor_map])
        expect(expected_json["metadata"]["ms:degree"]).to eq(degree_map)
      end

      context 'will have be able to map correct access_right' do
        it 'have public access rights' do
          access_right = ['open_access']
          expect(repository).to receive(:work_access_right_codes).with(work: work).and_return(access_right)
          expect(repository).to receive(:scope_users_for_entity_and_roles).
            with(entity: work, roles: 'creating_user').and_return(creators)
          expect(work).to receive(:id).and_return('a_id')
          expect(work).to receive(:title).and_return(title)
          expect(work).to receive(:collaborators).and_return(collaborators)
          expected_json = JSON.parse(subject.call)
          expect(expected_json["rights"]).to eq("read-groups" => ["public"], "read" => ['Hello'], "edit" => [batch_user])
        end

        it 'have restricted access rights' do
          access_right = ['restricted_access']
          expect(repository).to receive(:work_access_right_codes).with(work: work).and_return(access_right)
          expect(repository).to receive(:scope_users_for_entity_and_roles).
            with(entity: work, roles: 'creating_user').and_return(creators)
          expect(work).to receive(:id).and_return('a_id')
          expect(work).to receive(:title).and_return(title)
          expect(work).to receive(:collaborators).and_return(collaborators)
          expected_json = JSON.parse(subject.call)
          expect(expected_json["rights"]).to eq("read-groups" => ["restricted"], "read" => ['Hello'], "edit" => [batch_user])
        end

        context 'will add embargo date to rights metadata' do
          let(:embargo_date) { "2022-12-01" }
          it 'return embargo date' do
            access_rights = Models::AccessRight.new(access_right_code: 'embargo_then_open_access',
                                                    release_date: Time.zone.today, transition_date: embargo_date)
            expect(repository).to receive(:work_access_right_codes).with(work: work).
              and_return([access_rights.access_right_code])
            expect(repository).to receive(:scope_users_for_entity_and_roles).
              with(entity: work, roles: 'creating_user').and_return(creators)
            expect(work).to receive(:access_rights).and_return([access_rights])
            expect(work).to receive(:id).and_return('a_id')
            expect(work).to receive(:title).and_return(title)
            expect(work).to receive(:collaborators).and_return(collaborators)
            expected_json = JSON.parse(subject.call)
            expect(expected_json["rights"]).to eq("embargo-date" => embargo_date, "read-groups" => ["public"],
                                                  "read" => ['Hello'], "edit" => [batch_user])
          end

          it 'have public access rights with embargo date' do
            access_right = ['embargo_then_open_access']
            expect(repository).to receive(:work_access_right_codes).with(work: work).and_return(access_right)
            expect(subject).to receive(:embargo_date).and_return(embargo_date)
            expect(repository).to receive(:scope_users_for_entity_and_roles).
              with(entity: work, roles: 'creating_user').and_return(creators)
            expect(work).to receive(:id).and_return('a_id')
            expect(work).to receive(:title).and_return(title)
            expect(work).to receive(:collaborators).and_return(collaborators)
            expected_json = JSON.parse(subject.call)
            expect(expected_json["rights"]).to eq("embargo-date" => embargo_date, "read-groups" => ["public"],
                                                  "read" => ['Hello'], "edit" => [batch_user])
          end
        end
      end
    end
  end
end
