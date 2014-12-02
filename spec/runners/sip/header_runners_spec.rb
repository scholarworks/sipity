require 'spec_helper'
require 'sip/header_runners'

module Sip
  module HeaderRunners
    RSpec.describe New do
      let(:header) { double }
      let(:context) { double(repository: repository) }
      let(:repository) { double(build_create_header_form: header) }
      let(:handler) { double(invoked: true) }
      subject do
        described_class.new(context) do |on|
          on.success { |header| handler.invoked("SUCCESS", header) }
        end
      end

      it 'issues the :success callback' do
        response = subject.run
        expect(handler).to have_received(:invoked).with("SUCCESS", header)
        expect(response).to eq([:success, header])
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
        expect(response).to eq([:success, header])
      end
    end

    RSpec.describe Create do
      let(:header) { double('Header') }
      let(:form) { double('Form') }
      let(:context) { double('Context', repository: repository) }
      let(:repository) do
        double('Repository', build_create_header_form: form, submit_create_header_form: creation_response)
      end
      let(:handler) { double(invoked: true) }
      let(:attributes) { {} }
      subject do
        described_class.new(context) do |on|
          on.success { |a| handler.invoked("SUCCESS", a) }
          on.failure { |a| handler.invoked("FAILURE", a) }
        end
      end

      context 'when header is saved' do
        let(:creation_response) { header }
        it 'will issue the :success callback and return the header' do
          response = subject.run(attributes: attributes)
          expect(handler).to have_received(:invoked).with("SUCCESS", header)
          expect(response).to eq([:success, header])
        end
      end

      context 'when header is not saved' do
        let(:creation_response) { false }
        it 'will issue the :failure callback and return the form' do
          response = subject.run(attributes: attributes)
          expect(handler).to have_received(:invoked).with("FAILURE", form)
          expect(response).to eq([:failure, form])
        end
      end
    end
  end
end
