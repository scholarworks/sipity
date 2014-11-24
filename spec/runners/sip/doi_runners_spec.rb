require 'spec_helper'
require 'sip/doi_runners'

module Sip
  module DoiRunners
    RSpec.describe Show do
      let(:header) { double }
      let(:header_id) { 1234 }
      let(:context) { double(repository: repository) }
      let(:repository) { double(find_header: header, doi_already_assigned?: false, doi_request_is_pending?: false) }
      let(:handler) { double(invoked: true) }
      subject do
        described_class.new(context) do |on|
          on.doi_already_assigned { |header| handler.invoked("DOI_ALREADY_ASSIGNED", header) }
          on.doi_not_assigned { |header| handler.invoked("DOI_NOT_ASSIGNED", header) }
          on.doi_request_is_pending { |header| handler.invoked("DOI_REQUEST_IS_PENDING", header) }
        end
      end

      context 'when a DOI is assigned' do
        it 'issues the :doi_already_assigned callback' do
          expect(repository).to receive(:doi_already_assigned?).and_return true
          response = subject.run(header_id: header_id)
          expect(handler).to have_received(:invoked).with("DOI_ALREADY_ASSIGNED", header)
          expect(response).to eq([header])
        end
      end

      context 'when a DOI is not assigned' do
        it 'issues the :doi_not_assigned callback' do
          response = subject.run(header_id: header_id)
          expect(handler).to have_received(:invoked).with("DOI_NOT_ASSIGNED", header)
          expect(response).to eq([header])
        end
      end

      context 'when a DOI request has been made but not yet completed' do
        it 'issues the :pending_doi_assignment callback' do
          expect(repository).to receive(:doi_request_is_pending?).and_return(true)
          response = subject.run(header_id: header_id)
          expect(handler).to have_received(:invoked).with("DOI_REQUEST_IS_PENDING", header)
          expect(response).to eq([header])
        end
      end
    end

    RSpec.describe Assign do
      let(:header) { double }
      let(:header_id) { 1234 }
      let(:identifier) { 'abc:123' }
      let(:context) { double(repository: repository) }
      let(:form) { double('Form', submit: true, identifier: identifier, header: header, identifier_key: 'key') }
      let(:repository) { double(find_header: header, build_header_doi_form: form, create_additional_attribute: true) }
      let(:handler) { double(invoked: true) }
      subject do
        described_class.new(context) do |on|
          on.success { |header, identifier| handler.invoked("SUCCESS", header, identifier) }
          on.failure { |header| handler.invoked("FAILURE", header) }
        end
      end

      context 'when the form submission fails' do
        it 'issues the :failure callback' do
          expect(form).to receive(:submit).and_return(false)
          response = subject.run(header_id: header_id, identifier: identifier)
          expect(handler).to have_received(:invoked).with("FAILURE", form)
          expect(response).to eq([form])
        end
      end

      context 'when the form submission succeeds' do
        it 'issues the :success callback' do
          expect(form).to receive(:submit).and_return(true).and_yield(form)
          expect(repository).to receive(:create_additional_attribute).
            with(header: header, key: form.identifier_key, value: form.identifier)
          response = subject.run(header_id: header_id, identifier: identifier)
          expect(handler).to have_received(:invoked).with("SUCCESS", header, identifier)
          expect(response).to eq([header, identifier])
        end
      end
    end
  end
end
