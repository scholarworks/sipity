require 'spec_helper'

module Sipity
  module Jobs
    RSpec.describe DoiCreationRequestJob do
      let(:doi_creation_request) do
        Models::DoiCreationRequest.create!(header: header, state: Models::DoiCreationRequest::REQUEST_NOT_YET_SUBMITTED)
      end
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
          gatherer = double(work: true)
          allow(described_class).to receive(:new).with(1234).and_return(gatherer)
          described_class.submit(1234)
          expect(gatherer).to have_received(:work)
        end
      end

      context 'defaults' do
        before do
          allow(Models::DoiCreationRequest).to receive(:find).with(1234).and_return double('Doi Creation Request')
        end
        subject { described_class.new(1234) }
        its(:minter) { should respond_to :call }
        its(:repository) { should respond_to :update_header_doi_creation_request_state! }
        its(:repository) { should respond_to :update_header_with_doi_predicate! }
        its(:repository) { should respond_to :gather_doi_creation_request_metadata }
      end

      context '#work' do
        before do
          allow(Models::DoiCreationRequest).to receive(:find).with(doi_creation_request.id).and_return doi_creation_request
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
