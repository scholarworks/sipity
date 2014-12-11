require 'spec_helper'

module Sipity
  module Services
    RSpec.describe DoiCreationRequestMetadataGatherer do
      let(:header) { Models::Header.new(id: 123, title: 'Live at Leeds') }
      subject { described_class.new(header_id: header.id) }

      context '.call' do
        it 'is a convenience method to expose the public API' do
          parameters = { header_id: 1 }
          gatherer = double(as_hash: true)
          allow(described_class).to receive(:new).with(parameters.fetch(:header_id)).and_return(gatherer)
          described_class.call(parameters)
          expect(gatherer).to have_received(:as_hash)
        end
      end

      context '#as_hash' do
        let(:creator) { 'Pete Townsend' }
        let(:publisher) { 'Decca' }
        let(:publication_date) { "#{publication_year}-05-23" }
        let(:publication_year) { '1970' }
        before do
          allow(Models::Header).to receive(:find).and_return(header)
          # TODO: Remove magic string
          Models::Collaborator.create!(header_id: header.id, role: 'author', name: creator)
          Models::AdditionalAttribute.create!(
            header_id: header.id, key: Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME, value: publisher
          )
          Models::AdditionalAttribute.create!(
            header_id: header.id, key: Models::AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME, value: publication_date
          )
        end
        it 'will collect data from various sources and return a string keyed hash' do
          expect(subject.as_hash).to eq(
            '_target' => "http://change.me/show/#{header.id}",
            'datacite.title' => header.title,
            'datacite.creator' => creator,
            'datacite.publisher' => publisher,
            'datacite.publicationyear' => publication_year
          )
        end
      end
    end
  end
end
