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
  end
end
