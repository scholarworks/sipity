require 'spec_helper'

module Sipity
  module Policies
    RSpec.describe WorkPolicy do
      let(:user) { User.new(id: '1') }
      let(:work) { Models::Work.new(id: '2') }
      let(:query_service) { double('Query Service') }
      subject { WorkPolicy.new(user, work, permission_query_service: query_service) }

      it 'has a default permission query service' do
        policy = WorkPolicy.new(user, work)
        service = policy.send(:permission_query_service)
        expect(service.call(user: user, entity: work, acting_as: ['hello_world'])).to eq(false)
      end

      context 'for a non-authenticated user' do
        let(:user) { nil }
        its(:show?) { should eq(false) }
        its(:create?) { should eq(false) }
        its(:update?) { should eq(false) }
        its(:destroy?) { should eq(false) }
      end

      context 'for an authenticated user' do
        context 'with an new work' do
          before { allow(work).to receive(:persisted?).and_return(false) }
          its(:show?) { should eq(false) }
          its(:create?) { should eq(true) }
          its(:update?) { should eq(false) }
          its(:destroy?) { should eq(false) }
        end
        context 'with an existing work' do
          before do
            allow(work).to receive(:persisted?).and_return(true)
          end
          before do
            allow(query_service).to receive(:call).
              with(user: user, entity: work, acting_as: [Models::Permission::CREATING_USER]).
              and_return(is_creating_user)
          end
          context 'that was created by the user' do
            let(:is_creating_user) { true }
            its(:show?) { should eq(true) }
            its(:update?) { should eq(true) }
            its(:create?) { should eq(false) }
            its(:destroy?) { should eq(true) }
          end
          context 'that was NOT created by the user' do
            let(:is_creating_user) { false }
            its(:show?) { should eq(false) }
            its(:update?) { should eq(false) }
            its(:create?) { should eq(false) }
            its(:destroy?) { should eq(false) }
          end
        end
      end
    end

    RSpec.describe WorkPolicy::Scope do
      let(:user) { User.new(id: 1234) }
      let(:entity) { Models::Work.new(id: 5678) }
      context '.resolve' do
        it 'will use the scope_entities_for_entity_type_and_user_acting_as' do
          allow(Queries::PermissionQueries).to receive(:scope_entities_for_entity_type_and_user_acting_as)
          described_class.resolve(user: user)
        end
      end
    end
  end
end
