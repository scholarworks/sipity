require "rails_helper"
require 'sipity/models/expanded_work'

module Sipity
  module Models
    RSpec.describe ExpandedWork do
      let(:work) { Models::Work.new(id: 1, work_type: 'doctoral_dissertation', title: 'Hello World') }
      let(:repository) { QueryRepositoryInterface.new }
      let(:expanded_work) { described_class.new(work: work, repository: repository) }
      let(:user) { instance_double(User, username: 'anetid') }

      subject { expanded_work }
      its(:default_repository) { is_expected.to respond_to(:scope_users_for_entity_and_roles) }
      its(:default_repository) { is_expected.to respond_to(:work_attachments) }
      it { is_expected.to delegate_method(:as_json).to(:to_hash) }
      it { is_expected.to delegate_method(:to_json).to(:to_hash) }
      it { is_expected.to delegate_method(:to_param).to(:work) }
      it { is_expected.to delegate_method(:id).to(:work).as(:to_param) }
      it { is_expected.to delegate_method(:work_type).to(:work) }
      it { is_expected.to delegate_method(:title).to(:work) }
      its(:to_work) { is_expected.to eq(work) }

      context '#to_hash' do
        subject { expanded_work.to_hash }
        it { is_expected.to be_a(Hash) }
        its(:keys) do
          is_expected.to eq([:id, :type, :links, :attributes])
        end
        context '#[:id]' do
          subject { expanded_work.to_hash[:id] }
          it { is_expected.to eq(expanded_work.to_param) }
        end
        context '#[:type]' do
          subject { expanded_work.to_hash[:type] }
          it { is_expected.to eq(described_class::JSON_API_TYPE) }
        end
        context '#[:links]' do
          subject { expanded_work.to_hash[:links] }
          it { is_expected.to eq(self: "#{expanded_work.url}.json") }
        end
        context '#[:attributes]' do
          subject { expanded_work.to_hash[:attributes] }
          it { is_expected.to be_a(Hash) }
          its(:keys) do
            is_expected.to eq(
              [:url, :title, :work_type, :processing_state, :creating_users, :files, :collaborators, :additional_attributes]
            )
          end
        end
      end
      context '#creating_users' do
        before do
          allow(repository).to receive(:scope_users_for_entity_and_roles).with(entity: work, roles: 'creating_user').and_return(user)
        end
        subject { expanded_work.creating_users }
        it { is_expected.to eq([{ netid: user.username }]) }
      end
      context '#url' do
        subject { expanded_work.url }
        it { is_expected.to be_a(String) }
      end
      context '#processing_state' do
        subject { expanded_work.processing_state }
        it { is_expected.to be_a(String) }
      end
      context '#collaborators' do
        let(:collaborator) { Models::Collaborator.new }
        before { allow(repository).to receive(:work_collaborators_for).with(work: work).and_return(collaborator) }
        subject { expanded_work.collaborators }
        it { is_expected.to be_a(Array) }
        it 'should be an Array of Hashes each with keys: name, role, email, netid, responsible_for_review' do
          expect(subject.first.keys).to eq([:name, :role, :email, :netid, :responsible_for_review])
        end
      end
      context '#files' do
        let(:attachment) { Models::Attachment.new }
        before { allow(repository).to receive(:work_attachments).with(work: work).and_return(attachment) }
        subject { expanded_work.files }
        it { is_expected.to be_a(Array) }
        it 'should be an Array of Hashes each with keys: name, role, email, netid, responsible_for_review' do
          expect(subject.first.keys).to eq([:file_name, :is_representative_file, :access_right_code, :release_date])
        end
      end
      context '#additional_attributes' do
        let(:attachment) { Models::Attachment.new }
        before do
          allow(repository).to receive(:work_attribute_key_value_pairs_for).with(work: work).and_return(
            [
              ['key', 'value'],
              ['key', 'value2'],
              ['chicken', 'nugget']
            ]
          )
        end
        subject { expanded_work.additional_attributes }
        it { is_expected.to be_a(Hash) }
        it 'should aggregate the returned key value pairs' do
          expect(subject).to eq('key' => ['value', 'value2'], 'chicken' => ['nugget'])
        end
      end
    end
  end
end
