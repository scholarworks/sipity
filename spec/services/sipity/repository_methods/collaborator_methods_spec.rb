require 'spec_helper'

module Sipity
  module RepositoryMethods
    RSpec.describe CollaboratorMethods, type: :repository_methods do
      let(:header) { Models::Header.new(id: '123') }
      let(:header_two) { Models::Header.new(id: '456') }
      subject { test_repository }

      context '.header_collaborators_for' do
        it 'returns the collaborators for the given header and role' do
          Models::Collaborator.create!(header: header, role: 'author')
          expect(subject.header_collaborators_for(header: header, role: 'author').count).to eq(1)
        end
        it 'returns the collaborators for the given header' do
          one = Models::Collaborator.create!(header: header, role: 'author')
          two = Models::Collaborator.create!(header: header, role: 'advisor')
          three = Models::Collaborator.create!(header: header_two, role: 'advisor')
          expect(subject.header_collaborators_for(header: header)).to eq([one, two])
          expect(subject.header_collaborators_for(role: 'advisor')).to eq([two, three])
        end
      end

      context '.header_collaborator_names_for' do
        it 'returns only the names' do
          Models::Collaborator.create!(header: header, role: 'author', name: 'John')
          expect(subject.header_collaborator_names_for(header: header)).to eq(['John'])
        end
      end
    end
  end
end
