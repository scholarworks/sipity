require 'spec_helper'

module Sipity
  module Policies
    RSpec.describe HeaderPolicy do
      let(:user) { User.new(id: '1') }
      let(:header) { Models::Header.new(id: '2') }
      let(:query_service) { double('Query Service') }
      subject { HeaderPolicy.new(user, header, permission_query_service: query_service) }

      it 'has a default permission query service' do
        policy = HeaderPolicy.new(user, header)
        service = policy.send(:permission_query_service)
        expect(service.call(user: user, entity: header, roles: ['hello_world'])).to eq(false)
      end

      context 'for a non-authenticated user' do
        let(:user) { nil }
        its(:show?) { should eq(false) }
        its(:create?) { should eq(false) }
        its(:update?) { should eq(false) }
        its(:destroy?) { should eq(false) }
      end

      context 'for an authenticated user' do
        context 'with an new header' do
          before { allow(header).to receive(:persisted?).and_return(false) }
          its(:show?) { should eq(false) }
          its(:create?) { should eq(true) }
          its(:update?) { should eq(false) }
          its(:destroy?) { should eq(false) }
        end
        context 'with an existing header' do
          before do
            allow(header).to receive(:persisted?).and_return(true)
          end
          before do
            allow(query_service).to receive(:call).
              with(user: user, entity: header, roles: [Models::Permission::CREATING_USER]).
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

    RSpec.describe HeaderPolicy::Scope do
      let(:user) { User.new(id: 1234) }
      let(:group) { Models::Group.new(id: 5678) }
      let(:entity) { Models::Header.create! }
      context '.resolve' do

        it 'will return the entity for the creating user' do
          # TODO: Tease apart this service method; Its a command that I want to
          #   leverage.
          # TODO: I have knowledge of the applicable ROLE, this should be passed to the
          #   resolver.
          Models::Permission.create!(entity: entity, actor: user, role: Models::Permission::CREATING_USER)
          expect(HeaderPolicy::Scope.resolve(user: user)).to include(entity)
        end

        it 'will exclude the entity for a non creating user' do
          expect(HeaderPolicy::Scope.resolve(user: user)).to_not include(entity)
        end

        it 'will return the entity for which the user is inferred by group' do
          Models::GroupMembership.create!(user: user, group: group)
          # TODO: Tease apart this service method; Its a command that I want to
          #   leverage.
          # TODO: I have knowledge of the applicable ROLE, this should be passed to the
          #   resolver.
          Models::Permission.create!(entity: entity, actor: group, role: Models::Permission::CREATING_USER)
          expect(HeaderPolicy::Scope.resolve(user: user)).to include(entity)
        end

        it 'will exclude the entity for which the user is not part of the group' do
          Models::Permission.create!(entity: entity, actor: group, role: Models::Permission::CREATING_USER)
          expect(HeaderPolicy::Scope.resolve(user: user)).to_not include(entity)
        end
      end
    end
  end
end
