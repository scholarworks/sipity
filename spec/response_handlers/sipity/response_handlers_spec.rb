require 'spec_helper'

module Sipity
  RSpec.describe ResponseHandlers do
    before do
      module MockContainer
        module SuccessResponse
          def self.respond(**_keywords)
          end
        end
      end
    end
    after { Sipity.send(:remove_const, :MockContainer) }
    let(:context) { double }
    let(:handled_response) { double(status: :success) }

    context '.handle_response' do
      it 'will build a handler then respond with that handler' do
        expect(MockContainer::SuccessResponse).to receive(:respond).with(context: context, handled_response: handled_response)
        described_class.handle_response(container: MockContainer, context: context, handled_response: handled_response)
      end
    end

    context '.build_response_handler' do
      it 'will return a response handler object' do
        actual = described_class.build_response_handler(container: MockContainer, handled_response_status: :success)
        expect(actual).to eq(MockContainer::SuccessResponse)
      end
    end
  end
end
