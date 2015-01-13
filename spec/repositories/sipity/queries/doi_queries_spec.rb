require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe DoiQueries, type: :repository_methods do
      context '#find_doi_creation_request' do
        let(:work) { Models::Sip.new(id: 123) }
        it 'will find based on the work' do
          entity = Models::DoiCreationRequest.create!(work: work)
          expect(test_repository.find_doi_creation_request(work: work)).to eq(entity)
        end
        it 'will raise an exception if one cannot be found' do
          expect { test_repository.find_doi_creation_request(work: work) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context '#gather_doi_creation_request_metadata' do
        it 'will delegate to the gather' do
          work = double
          expect(Services::DoiCreationRequestMetadataGatherer).to receive(:call).with(work: work)
          test_repository.gather_doi_creation_request_metadata(work: work)
        end
      end

      context '#build_assign_a_doi_form object' do
        let(:work) { double }
        subject { test_repository.build_assign_a_doi_form(work: work) }
        it { should respond_to :work }
        it { should respond_to :identifier }
        it { should respond_to :identifier_key }
        it { should respond_to :submit }
      end

      context '#build_request_a_doi_form object' do
        let(:work) { double }
        subject { test_repository.build_request_a_doi_form(work: work) }
        it { should respond_to :title }
        it { should respond_to :authors }
        it { should respond_to :publication_date }
        it { should respond_to :publisher }
        it { should respond_to :submit }
      end

      context '#doi_request_is_pending?' do
        let(:work) { Models::Sip.new(id: 1) }
        it 'will see if a DOI Creation Request exists' do
          expect(test_repository.doi_request_is_pending?(work)).to be_falsey
        end
      end

      context '#doi_already_assigned?' do
        let(:work) { Models::Sip.new(id: 1) }
        it 'will see if a DOI has been assigned to the work' do
          expect(test_repository.doi_already_assigned?(work)).to be_falsey
        end
      end
    end
  end
end
