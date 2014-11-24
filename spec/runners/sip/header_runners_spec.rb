require 'spec_helper'

module Sip
  describe HeaderRunners::New do
    let(:header) { double }
    let(:context) { double(repository: repository) }
    let(:repository) { double(build_header: header) }
    let(:handler) { double(invoked: true) }
    subject do
      HeaderRunners::New.new(context) do |on|
        on.success { |header| handler.invoked("SUCCESS", header) }
      end
    end

    it 'issues the :success callback' do
      response = subject.run
      expect(handler).to have_received(:invoked).with("SUCCESS", header)
      expect(response).to eq([header])
    end
  end
end
