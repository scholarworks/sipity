require 'spec_helper'

module Sipity
  module Jobs
    RSpec.describe DoiCreationRequestJob do
      let(:doi_creation_request) { Models::DoiCreationRequest.create!(header: header) }
      let(:header) { Models::Header.create!(title: 'Hello', work_publication_strategy: 'do_not_know') }
      let(:minter) { double('Minter') }
      let(:repository) { Repository.new }
      let(:response) { double(id: 'doi:oh-my') }
      let(:metadata) { double('Metadata') }
      subject do
        described_class.new(
          doi_creation_request.id, repository: repository, minter: minter, minter_handled_exceptions: RuntimeError
        )
      end

      context '.submit' do
        it 'is a convenience method to expose the public API' do
          job = double(work: true)
          allow(described_class).to receive(:new).with(1234).and_return(job)
          described_class.submit(1234)
          expect(job).to have_received(:work)
        end
      end

      context 'defaults' do
        let(:an_id) { 1234 }
        before do
          # Not a fan of allow_any_instance_of but it helps with understanding default
          # behavior.
          allow_any_instance_of(Repository).to receive(:find_doi_creation_request_by_id).
            with(an_id).and_return doi_creation_request
        end
        subject { described_class.new(an_id) }
        its(:minter) { should respond_to :call }
        its(:repository) { should respond_to :update_header_doi_creation_request_state! }
        its(:repository) { should respond_to :update_header_with_doi_predicate! }
        its(:repository) { should respond_to :gather_doi_creation_request_metadata }
        its(:repository) { should respond_to :find_doi_creation_request_by_id }
      end

      context '#work' do
        before do
          expect(repository).to receive(:find_doi_creation_request_by_id).
            with(doi_creation_request.id).and_return doi_creation_request
        end

        it 'will ensure the doi_creation_request is in a proper state' do
          allow(doi_creation_request).to receive(:request_not_yet_submitted?).and_return false
          allow(doi_creation_request).to receive(:request_failed?).and_return false
          expect { subject.work }.to raise_error(Exceptions::InvalidDoiCreationRequestStateError)
        end

        context 'with invalid remote metadata' do
          it 'will transition the state through REQUEST_SUBMITTED to REQUEST_FAILED' do
            doi_creation_request.state = doi_creation_request.class::REQUEST_NOT_YET_SUBMITTED
            expect(minter).to receive(:call).and_raise(RuntimeError)
            expect { subject.work }.to raise_error(RuntimeError)
          end
        end

        context 'with valid remote metadata' do
          it 'will transition the state through REQUEST_SUBMITTED to REQUEST_COMPLETED and set the identifier.doi' do
            expect(repository).to receive(:gather_doi_creation_request_metadata).and_return(metadata)
            expect(minter).to receive(:call).with(metadata).and_return(response)
            subject.work
            expect(Repo::Support::AdditionalAttributes.values_for(header: header, key: Models::AdditionalAttribute::DOI_PREDICATE_NAME)).
              to eq([response.id])
          end
        end
      end
    end
  end
end
