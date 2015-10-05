require 'spec_helper'
require 'sipity/models/identifiable_agent'

module Sipity
  RSpec.describe Models::IdentifiableAgent do
    context '.new_from_collaborator' do
      context 'with an email' do
        let(:collaborator) { Models::Collaborator.new(identifier_id: '123', email: 'hello@world.com', name: 'Hello World') }
        subject { described_class.new_from_collaborator(collaborator: collaborator) }

        its(:to_s) { should eq(collaborator.name) }
        its(:name) { should eq(collaborator.name) }
        its(:identifier_id) { should eq(collaborator.identifier_id )}
        its(:email) { should eq(collaborator.email) }
      end

      context 'with a netid' do
        let(:collaborator) { Models::Collaborator.new(identifier_id: '123', netid: 'hworld', name: 'Hello World') }
        subject { described_class.new_from_collaborator(collaborator: collaborator) }

        its(:to_s) { should eq(collaborator.name) }
        its(:name) { should eq(collaborator.name) }
        its(:identifier_id) { should eq(collaborator.identifier_id )}
        its(:email) { should eq("#{collaborator.netid}@nd.edu") }
      end
    end
  end
end
