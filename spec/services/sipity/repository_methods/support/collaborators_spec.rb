require 'spec_helper'

module Sipity
  module RepositoryMethods
    module Support
      RSpec.describe Collaborators do
        let(:header) { Models::Header.new(id: '123') }
        let(:header_two) { Models::Header.new(id: '456') }
        subject { described_class }

        context '.for' do
          it 'returns the collaborators for the given header and role' do
            Models::Collaborator.create!(header: header, role: 'author')
            expect(subject.for(header: header, role: 'author').count).to eq(1)
          end
          it 'returns the collaborators for the given header' do
            one = Models::Collaborator.create!(header: header, role: 'author')
            two = Models::Collaborator.create!(header: header, role: 'advisor')
            three = Models::Collaborator.create!(header: header_two, role: 'advisor')
            expect(subject.for(header: header)).to eq([one, two])
            expect(subject.for(role: 'advisor')).to eq([two, three])
          end
        end

        context '.names_for' do
          it 'returns only the names' do
            Models::Collaborator.create!(header: header, role: 'author', name: 'John')
            expect(subject.names_for(header: header)).to eq(['John'])
          end
        end
      end
    end
  end
end
