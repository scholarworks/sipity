require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe DoiQueries, type: :repository_methods do
      context '#find_doi_creation_request' do
        let(:sip) { Models::Sip.new(id: 123) }
        it 'will find based on the sip' do
          entity = Models::DoiCreationRequest.create!(sip: sip)
          expect(test_repository.find_doi_creation_request(sip: sip)).to eq(entity)
        end
        it 'will raise an exception if one cannot be found' do
          expect { test_repository.find_doi_creation_request(sip: sip) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context '#gather_doi_creation_request_metadata' do
        it 'will delegate to the gather' do
          sip = double
          expect(Services::DoiCreationRequestMetadataGatherer).to receive(:call).with(sip: sip)
          test_repository.gather_doi_creation_request_metadata(sip: sip)
        end
      end

      context '#build_assign_a_doi_form object' do
        let(:sip) { double }
        subject { test_repository.build_assign_a_doi_form(sip: sip) }
        it { should respond_to :sip }
        it { should respond_to :identifier }
        it { should respond_to :identifier_key }
        it { should respond_to :submit }
      end

      context '#build_request_a_doi_form object' do
        let(:sip) { double }
        subject { test_repository.build_request_a_doi_form(sip: sip) }
        it { should respond_to :title }
        it { should respond_to :authors }
        it { should respond_to :publication_date }
        it { should respond_to :publisher }
        it { should respond_to :submit }
      end

      context '#doi_request_is_pending?' do
        let(:sip) { Models::Sip.new(id: 1) }
        it 'will see if a DOI Creation Request exists' do
          expect(test_repository.doi_request_is_pending?(sip)).to be_falsey
        end
      end

      context '#doi_already_assigned?' do
        let(:sip) { Models::Sip.new(id: 1) }
        it 'will see if a DOI has been assigned to the sip' do
          expect(test_repository.doi_already_assigned?(sip)).to be_falsey
        end
      end
    end
  end
end
