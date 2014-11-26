require 'spec_helper'
require 'sip/header_runners'

module Sip
  module HeaderRunners
    RSpec.describe New do
      let(:header) { double }
      let(:context) { double(repository: repository) }
      let(:repository) { double(build_header: header) }
      let(:handler) { double(invoked: true) }
      subject do
        described_class.new(context) do |on|
          on.success { |header| handler.invoked("SUCCESS", header) }
        end
      end

      it 'issues the :success callback' do
        response = subject.run
        expect(handler).to have_received(:invoked).with("SUCCESS", header)
        expect(response).to eq([header])
      end
    end

    RSpec.describe Show do
      let(:header) { double }
      let(:context) { double(repository: repository) }
      let(:repository) { double(find_header: header) }
      let(:handler) { double(invoked: true) }
      subject do
        described_class.new(context) do |on|
          on.success { |header| handler.invoked("SUCCESS", header) }
        end
      end

      it 'issues the :success callback' do
        response = subject.run(1234)
        expect(handler).to have_received(:invoked).with("SUCCESS", header)
        expect(response).to eq([header])
      end
    end

    RSpec.describe Create do
      let(:header) { double }
      let(:context) { double(repository: repository) }
      let(:repository) { double(build_header: header, submit_create_header_form: creation_response) }
      let(:handler) { double(invoked: true) }
      let(:attributes) { {} }
      subject do
        described_class.new(context) do |on|
          on.success { |header| handler.invoked("SUCCESS", header) }
          on.failure { |header| handler.invoked("FAILURE", header) }
        end
      end

      context 'when header is saved' do
        let(:creation_response) { true }
        it 'will issue the :success callback' do
          response = subject.run(attributes: attributes)
          expect(handler).to have_received(:invoked).with("SUCCESS", header)
          expect(response).to eq([header])
        end
      end

      context 'when header is not saved' do
        let(:creation_response) { false }
        it 'will issue the :failure callback' do
          response = subject.run(attributes: attributes)
          expect(handler).to have_received(:invoked).with("FAILURE", header)
          expect(response).to eq([header])
        end
      end
    end
  end
end
