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
        let(:token) { double("Token - because relying on a Token generated via Cogitate and its configuration may be painful") }
        let(:token_decoder) { double('Token Decoder', call: agent) }
        let(:agent) do
          Cogitate::Models::Agent.build_with_identifying_information(strategy: 'netid', identifying_value: 'hworld') do |the_agent|
            the_agent.add_email('hworld@nd.edu')
          end
        end

        subject { Agent.new_from_cogitate_token(token: token, token_decoder: token_decoder) }
        its(:email) { should eq('hworld@nd.edu') }
        it { should delegate_method(:ids).to(:cogitate_agent) }
        it { should delegate_method(:name).to(:cogitate_agent) }
      end
    end
  end
end
