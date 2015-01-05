require 'spec_helper'

module Sipity
  module Policies
    RSpec.describe SipPolicy do
      let(:user) { User.new(id: '1') }
      let(:sip) { Models::Sip.new(id: '2') }
      let(:query_service) { double('Query Service') }
      subject { SipPolicy.new(user, sip, permission_query_service: query_service) }

      it 'has a default permission query service' do
        policy = SipPolicy.new(user, sip)
        service = policy.send(:permission_query_service)
        expect(service.call(user: user, entity: sip, roles: ['hello_world'])).to eq(false)
      end

      context 'for a non-authenticated user' do
        let(:user) { nil }
        its(:show?) { should eq(false) }
        its(:create?) { should eq(false) }
        its(:update?) { should eq(false) }
        its(:destroy?) { should eq(false) }
      end

      context 'for an authenticated user' do
        context 'with an new sip' do
          before { allow(sip).to receive(:persisted?).and_return(false) }
          its(:show?) { should eq(false) }
          its(:create?) { should eq(true) }
          its(:update?) { should eq(false) }
          its(:destroy?) { should eq(false) }
        end
        context 'with an existing sip' do
          before do
            allow(sip).to receive(:persisted?).and_return(true)
          end
          before do
            allow(query_service).to receive(:call).
              with(user: user, entity: sip, roles: [Models::Permission::CREATING_USER]).
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

    RSpec.describe SipPolicy::Scope do
      let(:user) { User.new(id: 1234) }
      let(:entity) { Models::Sip.new(id: 5678) }
      context '.resolve' do
        it 'will use the scope_entities_for_user_and_roles' do
          allow(Queries::PermissionQueries).to receive(:scope_entities_for_user_and_roles)
          described_class.resolve(user: user)
        end
      end
    end
  end
end
