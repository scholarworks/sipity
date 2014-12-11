require 'spec_helper'

module Sipity
  module Jobs
    RSpec.describe DoiCreationRequestJob do
      let(:doi_creation_request) { Models::DoiCreationRequest.new(id: 123) }
      let(:minter) { double(call: true) }
      let(:identifier) { double('Identifier') }
      subject { described_class.new(doi_creation_request.id, minter: minter, minter_handled_exceptions: RuntimeError) }
      before do
        allow(Models::DoiCreationRequest).to receive(:find).with(doi_creation_request.id).and_return doi_creation_request
      end

      context '#work' do
        before do
        end

        it 'will guard against incorrect state' do
          expect { subject.work }.to raise_error(RuntimeError)
        end

        context 'with invalid remote metadata' do
          it 'will transition the state through REQUEST_SUBMITTED to REQUEST_FAILED' do
            doi_creation_request.state = doi_creation_request.class::REQUEST_NOT_YET_SUBMITTED
            expect(doi_creation_request).to receive(:update).with(state: doi_creation_request.class::REQUEST_SUBMITTED).ordered
            expect(doi_creation_request).to receive(:update).with(state: doi_creation_request.class::REQUEST_FAILED).ordered
            expect(minter).to receive(:call).and_raise(RuntimeError)
            subject.work
          end
        end

        context 'with valid remote metadata' do
          it 'will transition the state through REQUEST_SUBMITTED to REQUEST_FAILED' do
            doi_creation_request.state = doi_creation_request.class::REQUEST_NOT_YET_SUBMITTED
            expect(doi_creation_request).to receive(:update).with(state: doi_creation_request.class::REQUEST_SUBMITTED).ordered
            expect(doi_creation_request).to receive(:update).with(state: doi_creation_request.class::REQUEST_COMPLETED).ordered
            expect(minter).to receive(:call).and_return(identifier)
            subject.work
          end
        end
      end
    end
  end
end
