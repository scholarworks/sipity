require 'spec_helper'

module Sipity
  module Services
    RSpec.describe DoiCreationRequestMetadataGatherer do
      let(:sip) { Models::Sip.new(id: 123, title: 'Live at Leeds') }
      subject { described_class.new(sip) }

      context '.call' do
        it 'is a convenience method to expose the public API' do
          parameters = { sip: sip }
          gatherer = double(as_hash: true)
          allow(described_class).to receive(:new).with(parameters.fetch(:sip)).and_return(gatherer)
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
          # TODO: Remove magic string
          Models::Collaborator.create!(sip_id: sip.id, role: Models::Collaborator::AUTHOR_ROLE, name: creator)
          Models::AdditionalAttribute.create!(
            sip_id: sip.id, key: Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME, value: publisher
          )
          Models::AdditionalAttribute.create!(
            sip_id: sip.id, key: Models::AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME, value: publication_date
          )
        end
        it 'will collect data from various sources and return a string keyed hash' do
          expect(subject.as_hash).to eq(
            '_target' => Conversions::ConvertToPermanentUri.call(sip.id),
            'datacite.title' => sip.title,
            'datacite.creator' => creator,
            'datacite.publisher' => publisher,
            'datacite.publicationyear' => publication_year
          )
        end
      end
    end
  end
end
