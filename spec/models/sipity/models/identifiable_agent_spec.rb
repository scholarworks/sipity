require 'spec_helper'
require 'sipity/models/identifiable_agent'

module Sipity
  RSpec.describe Models::IdentifiableAgent do
    context '.new_from_collaborator' do
      context 'with an email' do
        let(:collaborator) { Models::Collaborator.new(identifier_id: '123', email: 'hello@world.com', name: 'Hello World') }
        subject { described_class.new_from_collaborator(collaborator: collaborator) }

        it { should contractually_honor(Sipity::Interfaces::IdentifiableAgentInterface) }
        its(:to_s) { should eq(collaborator.name) }
        its(:name) { should eq(collaborator.name) }
        its(:identifier_id) { should eq(collaborator.identifier_id) }
        its(:email) { should eq(collaborator.email) }
      end

      context 'with a netid' do
        let(:collaborator) { Models::Collaborator.new(identifier_id: '123', netid: 'hworld', name: 'Hello World') }
        subject { described_class.new_from_collaborator(collaborator: collaborator) }

        it { should contractually_honor(Sipity::Interfaces::IdentifiableAgentInterface) }
        its(:to_s) { should eq(collaborator.name) }
        its(:name) { should eq(collaborator.name) }
        its(:identifier_id) { should eq(collaborator.identifier_id) }
        its(:email) { should eq("#{collaborator.netid}@nd.edu") }
      end
    end

    context '.new_for_identifier_id' do
      let(:identifier_id) { Cogitate::Client.encoded_identifier_for(strategy: strategy, identifying_value: identifying_value) }
      subject { described_class.new_for_identifier_id(identifier_id: identifier_id) }
      context 'with email strategy' do
        let(:strategy) { 'email' }
        let(:identifying_value) { 'hello@world.com' }
        it { should contractually_honor(Sipity::Interfaces::IdentifiableAgentInterface) }

        its(:to_s) { should eq(identifying_value) }
        its(:name) { should eq(identifying_value) }
        its(:identifier_id) { should eq(identifier_id) }
        its(:email) { should eq(identifying_value) }
      end

      context 'with netid strategy' do
        let(:strategy) { 'netid' }
        let(:identifying_value) { 'hworld' }
        it { should contractually_honor(Sipity::Interfaces::IdentifiableAgentInterface) }

        its(:to_s) { should eq(identifying_value) }
        its(:name) { should eq(identifying_value) }
        its(:identifier_id) { should eq(identifier_id) }
        its(:email) { should eq("#{identifying_value}@nd.edu") }
      end

      context 'with a strange strategy' do
        let(:strategy) { 'strange' }
        let(:identifying_value) { 'hworld' }
        it { should contractually_honor(Sipity::Interfaces::IdentifiableAgentInterface) }

        its(:to_s) { should eq(identifying_value) }
        its(:name) { should eq(identifying_value) }
        its(:identifier_id) { should eq(identifier_id) }
        its(:email) { should eq(nil) }
      end
    end
  end
end
