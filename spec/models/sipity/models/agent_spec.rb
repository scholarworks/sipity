require 'spec_helper'
require 'cogitate/models/agent'

module Sipity
  module Models
    RSpec.describe Agent do
      context 'class configuration' do
        subject { described_class }
        its(:default_token_decoder) { should respond_to(:call) }
        its(:public_methods) { should_not include(:new) }
        its(:private_methods) { should include(:new) }
      end

      context '.new_from_cogitate_token' do
        let(:token) { 'A "Token" because relying on a Token generated via Cogitate and its configuration may be painful' }
        let(:token_decoder) { double('Token Decoder', call: agent) }
        let(:agent) do
          Cogitate::Models::Agent.build_with_identifying_information(strategy: 'netid', identifying_value: 'hworld') do |the_agent|
            the_agent.add_email('hworld@nd.edu')
          end
        end

        subject { Agent.new_from_cogitate_token(token: token, token_decoder: token_decoder) }
        its(:email) { should eq('hworld@nd.edu') }
        its(:default_ids_decoder) { should respond_to(:call) }
        it { should delegate_method(:ids).to(:cogitate_agent) }
        it { should delegate_method(:name).to(:cogitate_agent) }
        its(:user_signed_in?) { should eq(true) }

        context '#netid' do
          it 'will decode the ids' do
            expect(subject.netid).to eq('hworld')
          end
        end
      end

      context '.new_from_user_id' do
        before { allow(User).to receive(:find).with(user.id).and_return(user) }
        let(:user) { double(id: 123, email: 'hello@world.com', to_s: 'The user', username: 'hello') }
        subject { Agent.new_from_user_id(user_id: user.id) }
        its(:email) { should eq(user.email) }
        its(:name) { should eq(user.to_s) }
        its(:ids) { should eq([Cogitate::Client.encoded_identifier_for(strategy: 'netid', identifying_value: user.username)]) }
        its(:user_id) { should eq(user.id) }
        its(:user_signed_in?) { should eq(true) }
      end

      context '.new_null_agent' do
        subject { Agent.new_null_agent }
        its(:user_signed_in?) { should eq(false) }
      end
    end
  end
end
