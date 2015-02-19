require 'spec_helper'

module Sipity
  module Policies
    RSpec.describe WorkPolicy do
      let(:user) { User.new(id: '1') }
      let(:work) { Models::Work.new(id: '2') }
      subject { WorkPolicy.new(user, work) }

      context 'for a non-authenticated user' do
        let(:user) { nil }
        its(:create?) { should eq(false) }
      end

      context 'for an authenticated user' do
        context 'with an new work' do
          before { allow(work).to receive(:persisted?).and_return(false) }
          its(:create?) { should eq(true) }
        end
        context 'with an existing work' do
          before do
            allow(work).to receive(:persisted?).and_return(true)
          end
          its(:create?) { should eq(false) }
        end
      end
    end

    RSpec.describe WorkPolicy::Scope do
      let(:user) { User.new(id: 1234) }
      let(:entity) { Models::Work.new(id: 5678) }
      let(:repository) { QueryRepository.new }
      context '.resolve' do
        it 'will use the #scope_proxied_objects_for_the_user_and_proxy_for_type' do
          expect(repository).to receive(:scope_proxied_objects_for_the_user_and_proxy_for_type).and_call_original
          described_class.resolve(user: user, repository: repository)
        end

        it 'will handle a processing_state' do
          expect(repository).to receive(:scope_proxied_objects_for_the_user_and_proxy_for_type).and_call_original
          described_class.resolve(user: user, repository: repository, processing_state: 'new')
        end
      end
    end
  end
end
