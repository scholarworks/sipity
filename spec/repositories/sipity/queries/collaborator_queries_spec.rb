require 'spec_helper'

module Sipity
  module Queries
    RSpec.describe CollaboratorQueries, type: :repository_methods do
      let(:sip) { Models::Sip.new(id: '123') }
      let(:sip_two) { Models::Sip.new(id: '456') }
      subject { test_repository }

      context '.sip_collaborators_for' do
        it 'returns the collaborators for the given sip and role' do
          Models::Collaborator.create!(sip: sip, role: 'author')
          expect(subject.sip_collaborators_for(sip: sip, role: 'author').count).to eq(1)
        end
        it 'returns the collaborators for the given sip' do
          one = Models::Collaborator.create!(sip: sip, role: 'author')
          two = Models::Collaborator.create!(sip: sip, role: 'advisor')
          three = Models::Collaborator.create!(sip: sip_two, role: 'advisor')
          expect(subject.sip_collaborators_for(sip: sip)).to eq([one, two])
          expect(subject.sip_collaborators_for(role: 'advisor')).to eq([two, three])
        end
      end

      context '.sip_collaborator_names_for' do
        it 'returns only the names' do
          Models::Collaborator.create!(sip: sip, role: 'author', name: 'John')
          expect(subject.sip_collaborator_names_for(sip: sip)).to eq(['John'])
        end
      end
    end
  end
end
