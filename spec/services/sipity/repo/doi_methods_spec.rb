require 'rails_helper'

module Sipity
  module Repo
    RSpec.describe DoiMethods, type: :repository_methods do
      context '#update_header_doi_creation_request_state!' do
        let(:header) { Models::Header.new(id: 123) }
        let!(:doi_creation_request) { Models::DoiCreationRequest.create!(header: header) }
        context 'given a valid state' do
          let(:state) { 'request_completed' }
          it 'will update the state' do
            expect { test_repository.update_header_doi_creation_request_state!(header: header, state: state) }.
              to change { doi_creation_request.reload.state }.to(state)
          end
        end

        context 'given an invalid state' do
          let(:state) { 'not_valid_even_once' }
          it 'will raise an ArgumentError' do
            expect { test_repository.update_header_doi_creation_request_state!(header: header, state: state) }.
              to raise_error(ArgumentError)
          end
        end
      end

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

      context '#submit_assign_a_doi_form' do
        let(:header) { Models::Header.new(id: '1234') }
        let(:user) { User.new(id: '123') }
        let(:attributes) { { header: header, identifier: identifier } }
        let(:form) { test_repository.build_assign_a_doi_form(attributes) }

        context 'on invalid data' do
          let(:identifier) { '' }
          it 'returns false and does not assign a DOI' do
            expect(test_repository.submit_assign_a_doi_form(form, requested_by: user)).to eq(false)
          end
        end
        context 'on valid data' do
          let(:identifier) { 'doi:abc' }
          it 'will return true after assigning the DOI to the header and logging the event' do
            response = test_repository.submit_assign_a_doi_form(form, requested_by: user)
            expect(response).to be_truthy
            expect(test_repository.doi_already_assigned?(header)).to be_truthy
            expect(Models::EventLog.where(user: user, event_name: 'submit_assign_a_doi_form').count).to eq(1)
          end
        end
      end

      context '#gather_doi_creation_request_metadata' do
        it 'will delegate to the gather' do
          header = double
          expect(Services::DoiCreationRequestMetadataGatherer).to receive(:call).with(header: header)
          test_repository.gather_doi_creation_request_metadata(header: header)
        end
      end

      context '#submit_request_a_doi_form' do
        let(:user) { User.new(id: 12) }
        let(:header) { Models::Header.new(id: '1234') }
        let(:attributes) do
          { header: header, publisher: publisher, publication_date: '2014-10-11', authors: ['Frog', 'Toad'] }
        end
        let(:form) { test_repository.build_request_a_doi_form(attributes) }

        context 'on invalid data' do
          let(:publisher) { '' }
          it 'will return false and does not create the DOI request' do
            expect(test_repository.submit_request_a_doi_form(form, requested_by: user)).to eq(false)
          end
        end

        context 'on valid data' do
          let(:publisher) { 'Valid Publisher' }
          it 'will return true having created the DOI request, appended the captured attributes, and loggged the event' do
            expect(Jobs).to receive(:submit).with('doi_creation_request_job', kind_of(Fixnum))
            response = test_repository.submit_request_a_doi_form(form, requested_by: user)

            expect(response).to be_truthy
            expect(test_repository.doi_request_is_pending?(header)).to be_truthy
            expect(header.additional_attributes.count).to eq(2)
            expect(Models::EventLog.where(user: user, event_name: 'submit_request_a_doi_form').count).to eq(1)
          end
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

      context '#update_header_with_doi_predicate!' do
        let(:header) { Models::Header.new(id: 1) }
        let(:value) { 'doi:oh-my' }
        it 'will update the underlying doi predicates' do
          allow(Support::AdditionalAttributes).to receive(:update!).
            with(header: header, key: 'identifier.doi', values: value).and_call_original
          test_repository.update_header_with_doi_predicate!(header: header, values: value)
        end
      end
    end
  end
end
