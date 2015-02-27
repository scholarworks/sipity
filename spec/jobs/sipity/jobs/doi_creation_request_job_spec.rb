require 'spec_helper'

module Sipity
  module Jobs
    RSpec.describe DoiCreationRequestJob do
      let(:doi_creation_request) { Models::DoiCreationRequest.new(work: work) }
      let(:work) { Models::Work.new(id: 1, title: 'Hello') }
      let(:minter) { double('Minter') }
      let(:repository) { CommandRepository.new }
      let(:response) { double(id: 'doi:oh-my') }
      let(:metadata) { double('Metadata') }
      subject do
        described_class.new(work.id, repository: repository, minter: minter, minter_handled_exceptions: RuntimeError)
      end

      before do
        allow(repository).to receive(:find_work).with(work.id).and_return(work)
        allow(repository).to receive(:find_doi_creation_request).with(work: work).and_return(doi_creation_request)
      end

      context '.submit' do
        it 'is a convenience method to expose the public API' do
          job = double(call: true)
          allow(described_class).to receive(:new).with(1234).and_return(job)
          described_class.submit(1234)
          expect(job).to have_received(:call)
        end
      end

      context 'defaults' do
        before do
          # Not a fan of allow_any_instance_of but it helps with understanding default
          # behavior.
          allow_any_instance_of(CommandRepository).to receive(:find_work).with(work.id).and_return work
          allow_any_instance_of(CommandRepository).to receive(:find_doi_creation_request).with(work: work).and_return work
        end
        subject { described_class.new(work.id) }
        its(:minter) { should respond_to :call }
        its(:repository) { should respond_to :update_work_doi_creation_request_state! }
        its(:repository) { should respond_to :update_work_attribute_values! }
        its(:repository) { should respond_to :gather_doi_creation_request_metadata }
        its(:repository) { should respond_to :find_doi_creation_request }
        its(:repository) { should respond_to :find_work }
      end

      context '#call' do
        it 'will ensure the doi_creation_request is in a proper state' do
          allow(doi_creation_request).to receive(:request_not_yet_submitted?).and_return false
          allow(doi_creation_request).to receive(:request_failed?).and_return false
          expect { subject.call }.to raise_error(Exceptions::InvalidDoiCreationRequestStateError)
        end

        context 'with invalid remote metadata' do
          it 'will transition the state through REQUEST_SUBMITTED to REQUEST_FAILED' do
            expect(minter).to receive(:call).and_raise(RuntimeError)
            expect { subject.call }.to raise_error(RuntimeError)
          end
        end

        context 'with valid remote metadata' do
          it 'will transition the state through REQUEST_SUBMITTED to REQUEST_COMPLETED and set the identifier.doi' do
            expect(repository).to receive(:gather_doi_creation_request_metadata).and_return(metadata)
            expect(minter).to receive(:call).with(metadata).and_return(response)
            subject.call
            # This reaches beyond the normal responsibility; But I want to make sure it calls.
            expect(
              repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::DOI_PREDICATE_NAME)
            ).to eq([response.id])
          end
        end
      end
    end
  end
end
