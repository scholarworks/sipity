require 'spec_helper'

module Sipity
  module Policies
    RSpec.describe HeaderPolicy do
      let(:user) { User.new(id: '1') }
      let(:header) { Models::Header.new(id: '2') }
      let(:query_service) { double('Query Service') }
      subject { HeaderPolicy.new(user, header, permission_query_service: query_service) }

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
              with(user: user, subject: header, roles: ['creating_user']).
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
  end
end