require 'spec_helper'
require 'sipity/models/expanded_work'

module Sipity
  module Models
    RSpec.describe ExpandedWork do
      let(:work) { Models::Work.new(id: 1, work_type: 'doctoral_dissertation', title: 'Hello World') }
      let(:repository) { QueryRepositoryInterface.new }
      let(:expanded_work) { described_class.new(work: work, repository: repository) }
      let(:user) { instance_double(User, username: 'anetid') }
      before do
        allow(repository).to receive(:scope_users_for_entity_and_roles).with(entity: work, roles: 'creating_user').and_return([user])
      end

      subject { expanded_work }
      it { is_expected.to delegate_method(:as_json).to(:to_hash) }
      it { is_expected.to delegate_method(:to_json).to(:to_hash) }
      it { is_expected.to delegate_method(:id).to(:work) }
      it { is_expected.to delegate_method(:work_type).to(:work) }
      it { is_expected.to delegate_method(:title).to(:work) }
      its(:to_work) { is_expected.to eq(work) }

      context '#to_hash' do
        subject { expanded_work.to_hash }
        it { is_expected.to be_a(Hash) }
        its(:keys) do
          is_expected.to eq([:id, :url, :netid, :title, :work_type, :processing_state, :files, :collaborators, :additional_attributes])
        end
      end
      context '#netid' do
        subject { expanded_work.netid }
        it { is_expected.to be_a(String) }
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
    end
  end
end
