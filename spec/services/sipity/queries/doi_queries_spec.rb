require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe DoiQueries, type: :repository_methods do
      context '#find_doi_creation_request' do
        let(:header) { Models::Header.new(id: 123) }
        it 'will find based on the header' do
          entity = Models::DoiCreationRequest.create!(header: header)
          expect(test_repository.find_doi_creation_request(header: header)).to eq(entity)
        end
        it 'will raise an exception if one cannot be found' do
          expect { test_repository.find_doi_creation_request(header: header) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context '#gather_doi_creation_request_metadata' do
        it 'will delegate to the gather' do
          header = double
          expect(Services::DoiCreationRequestMetadataGatherer).to receive(:call).with(header: header)
          test_repository.gather_doi_creation_request_metadata(header: header)
        end
      end

      context '#build_assign_a_doi_form object' do
        let(:header) { double }
        subject { test_repository.build_assign_a_doi_form(header: header) }
        it { should respond_to :header }
        it { should respond_to :identifier }
        it { should respond_to :identifier_key }
        it { should respond_to :submit }
      end

      context '#build_request_a_doi_form object' do
        let(:header) { double }
        subject { test_repository.build_request_a_doi_form(header: header) }
        it { should respond_to :title }
        it { should respond_to :authors }
        it { should respond_to :publication_date }
        it { should respond_to :publisher }
        it { should respond_to :submit }
      end

      context '#doi_request_is_pending?' do
        let(:header) { Models::Header.new(id: 1) }
        it 'will see if a DOI Creation Request exists' do
          expect(test_repository.doi_request_is_pending?(header)).to be_falsey
        end
      end

      context '#doi_already_assigned?' do
        let(:header) { Models::Header.new(id: 1) }
        it 'will see if a DOI has been assigned to the header' do
          expect(test_repository.doi_already_assigned?(header)).to be_falsey
        end
      end
    end
  end
end
