require 'spec_helper'
require 'cogitate/models/agent'

module Sipity
  module Models
    RSpec.describe Agent do
      context 'class configuration' do
        subject { described_class }
        its(:default_token_decoder) { should respond_to(:call) }
        its(:default_data_coercer) { should respond_to(:call) }
      end

      context '.new_from_cogitate_token' do
        # TODO: This test has overly complicated setup; Simplify this
        let(:token) { 'A "Token" because relying on a Token generated via Cogitate and its configuration may be painful' }
        let(:token_decoder) { double('Token Decoder', call: agent) }
        let(:agent) do
          Cogitate::Models::Agent.build_with_identifying_information(strategy: 'netid', identifying_value: 'hworld') do |the_agent|
            the_agent.add_email('hworld@nd.edu')
          end
        end
        subject { Agent.new_from_cogitate_token(token: token, token_decoder: token_decoder) }
        it 'will honor the AgentInterface' do
          expect(Contract.valid?(subject, Sipity::Interfaces::AgentInterface)).to eq(true)
        end
      end

      context '.new_from_cogitate_data' do
        let(:data) { { cogitate: :data } }
        let(:data_coercer) { double('Token Decoder', call: agent) }
        let(:agent) do
          Cogitate::Models::Agent.build_with_identifying_information(strategy: 'netid', identifying_value: 'hworld') do |the_agent|
            the_agent.add_email('hworld@nd.edu')
          end
        end
        subject { Agent.new_from_cogitate_data(data: data, data_coercer: data_coercer) }
        it 'will honor the AgentInterface' do
          expect(Contract.valid?(subject, Sipity::Interfaces::AgentInterface)).to eq(true)
        end
      end

      context '.new_from_user_id' do
        before { allow(User).to receive(:find).with(user.id).and_return(user) }
        let(:user) { double(id: 123, email: 'hello@world.com', to_s: 'The user', username: 'hello') }
        subject { Agent.new_from_user_id(user_id: user.id) }
        it 'will honor the AgentInterface' do
          expect(Contract.valid?(subject, Sipity::Interfaces::AgentInterface)).to eq(true)
        end
      end

      context '.new_null_agent' do
        subject { Agent.new_null_agent }
        it 'will honor the AgentInterface' do
          expect(Contract.valid?(subject, Sipity::Interfaces::AgentInterface)).to eq(true)
        end
      end
    end
  end
end
