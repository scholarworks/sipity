require 'spec_helper'
require 'sip/citation_runners'

module Sip
  module CitationRunners
    RSpec.describe Show do
      let(:header) { double }
      let(:header_id) { 1234 }
      let(:context) { double(repository: repository) }
      let(:repository) { double(find_header: header) }
      let(:handler) { double(invoked: true) }
      subject do
        described_class.new(context) do |on|
          on.citation_not_assigned { |header| handler.invoked("CITATION_NOT_ASSIGNED", header) }
        end
      end

      context 'when a citation is not assigned' do
        it 'issues the :citation_not_assigned callback' do
          response = subject.run(header_id: header_id)
          expect(handler).to have_received(:invoked).with("CITATION_NOT_ASSIGNED", header)
          expect(response).to eq([header])
        end
      end
    end

    RSpec.describe New do
      let(:header) { double }
      let(:header_id) { 1234 }
      let(:context) { double(repository: repository) }
      let(:form) { double('Form') }
      let(:repository) { double(find_header: header, build_assign_a_citation_form: form) }
      let(:handler) { double(invoked: true) }
      subject do
        described_class.new(context) do |on|
          on.citation_not_assigned { |header| handler.invoked("CITATION_NOT_ASSIGNED", header) }
        end
      end

      context 'when a citation is not assigned' do
        it 'issues the :citation_not_assigned callback' do
          response = subject.run(header_id: header_id)
          expect(handler).to have_received(:invoked).with("CITATION_NOT_ASSIGNED", form)
          expect(response).to eq([form])
        end
      end
    end
  end
end
