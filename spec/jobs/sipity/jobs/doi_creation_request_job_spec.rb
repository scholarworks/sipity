require 'spec_helper'

module Sipity
  module Jobs
    RSpec.describe DoiCreationRequestJob do
      let(:doi_creation_request) { Models::DoiCreationRequest.new(id: 123) }
      let(:minter) { double(call: true) }
      subject { described_class.new(doi_creation_request.id, minter: minter) }
      before do
        allow(Models::DoiCreationRequest).to receive(:find).with(doi_creation_request.id).and_return doi_creation_request
      end

      context '#work' do
        before do
        end

        it 'will guard against incorrect state' do
          expect { subject.work }.to raise_error(RuntimeError)
        end

        it 'will transition the state to ' do
          doi_creation_request.state = doi_creation_request.class::REQUEST_NOT_YET_SUBMITTED
          allow(doi_creation_request).to receive(:update).with(state: doi_creation_request.class::REQUEST_SUBMITTED).ordered
          allow(doi_creation_request).to receive(:update).with(state: doi_creation_request.class::REQUEST_FAILED).ordered
          subject.work
        end
      end
    end
  end
end
