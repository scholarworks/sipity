require 'spec_helper'

module Sipity
  module Jobs
    RSpec.describe DoiCreationRequestJob do
      let(:doi_creation_request) { Models::DoiCreationRequest.new(header: header) }
      let(:header) { Models::Header.new(id: 1, title: 'Hello') }
      let(:minter) { double('Minter') }
      let(:repository) { Repository.new }
      let(:response) { double(id: 'doi:oh-my') }
      let(:metadata) { double('Metadata') }
      subject do
        described_class.new(header.id, repository: repository, minter: minter, minter_handled_exceptions: RuntimeError)
      end

      before do
        allow(repository).to receive(:find_header).with(header.id).and_return(header)
        allow(repository).to receive(:find_doi_creation_request).with(header: header).and_return(doi_creation_request)
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
        before do
          # Not a fan of allow_any_instance_of but it helps with understanding default
          # behavior.
          allow_any_instance_of(Repository).to receive(:find_header).with(header.id).and_return header
          allow_any_instance_of(Repository).to receive(:find_doi_creation_request).with(header: header).and_return header
        end
        subject { described_class.new(header.id) }
        its(:minter) { should respond_to :call }
        its(:repository) { should respond_to :update_header_doi_creation_request_state! }
        its(:repository) { should respond_to :update_header_with_doi_predicate! }
        its(:repository) { should respond_to :gather_doi_creation_request_metadata }
        its(:repository) { should respond_to :find_doi_creation_request }
        its(:repository) { should respond_to :find_header }
      end

      context '#work' do
        it 'will ensure the doi_creation_request is in a proper state' do
          allow(doi_creation_request).to receive(:request_not_yet_submitted?).and_return false
          allow(doi_creation_request).to receive(:request_failed?).and_return false
          expect { subject.work }.to raise_error(Exceptions::InvalidDoiCreationRequestStateError)
        end

        context 'with invalid remote metadata' do
          it 'will transition the state through REQUEST_SUBMITTED to REQUEST_FAILED' do
            expect(minter).to receive(:call).and_raise(RuntimeError)
            expect { subject.work }.to raise_error(RuntimeError)
          end
        end

        context 'with valid remote metadata' do
          it 'will transition the state through REQUEST_SUBMITTED to REQUEST_COMPLETED and set the identifier.doi' do
            expect(repository).to receive(:gather_doi_creation_request_metadata).and_return(metadata)
            expect(minter).to receive(:call).with(metadata).and_return(response)
            subject.work
            # TODO: This is stretching beyond the responsibilities of this layer
            expect(Repo::Support::AdditionalAttributes.values_for(header: header, key: Models::AdditionalAttribute::DOI_PREDICATE_NAME)).
              to eq([response.id])
          end
        end
      end
    end
  end
end
