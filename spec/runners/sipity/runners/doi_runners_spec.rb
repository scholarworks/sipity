require 'spec_helper'
require 'sipity/runners/doi_runners'

module Sipity
  module Runners
    module DoiRunners
      include RunnersSupport
      RSpec.describe Show do
        let(:header) { double }
        let(:header_id) { 1234 }
        let(:context) do
          TestRunnerContext.new(find_header: header, doi_already_assigned?: false, doi_request_is_pending?: false)
        end
        let(:handler) { double(invoked: true) }
        subject do
          described_class.new(context, requires_authentication: false) do |on|
            on.doi_already_assigned { |header| handler.invoked("DOI_ALREADY_ASSIGNED", header) }
            on.doi_not_assigned { |header| handler.invoked("DOI_NOT_ASSIGNED", header) }
            on.doi_request_is_pending { |header| handler.invoked("DOI_REQUEST_IS_PENDING", header) }
          end
        end

        it 'requires authentication' do
          expect(context).to receive(:authenticate_user!).and_return(true)
          described_class.new(context)
        end

        it 'requires authorization' do
          allow(subject).to receive(:with_authorization_enforcement).with(:show?, header)
          subject.run
          expect(handler).to_not have_received(:invoked)
        end

        context 'when a DOI is assigned' do
          it 'issues the :doi_already_assigned callback' do
            expect(context.repository).to receive(:doi_already_assigned?).and_return true
            response = subject.run(header_id: header_id)
            expect(handler).to have_received(:invoked).with("DOI_ALREADY_ASSIGNED", header)
            expect(response).to eq([:doi_already_assigned, header])
          end
        end

        context 'when a DOI is not assigned' do
          it 'issues the :doi_not_assigned callback' do
            response = subject.run(header_id: header_id)
            expect(handler).to have_received(:invoked).with("DOI_NOT_ASSIGNED", header)
            expect(response).to eq([:doi_not_assigned, header])
          end
        end

        context 'when a DOI request has been made but not yet completed' do
          it 'issues the :doi_request_is_pending callback' do
            expect(context.repository).to receive(:doi_request_is_pending?).and_return(true)
            response = subject.run(header_id: header_id)
            expect(handler).to have_received(:invoked).with("DOI_REQUEST_IS_PENDING", header)
            expect(response).to eq([:doi_request_is_pending, header])
          end
        end
      end

      RSpec.describe AssignADoi do
        let(:header) { double }
        let(:header_id) { 1234 }
        let(:identifier) { 'abc:123' }
        let(:form) { double('Form', submit: true, identifier: identifier, header: header, identifier_key: 'key') }
        let(:context) do
          TestRunnerContext.new(find_header: header, build_assign_a_doi_form: form, submit_assign_a_doi_form: true)
        end
        let(:handler) { double('Handler', invoked: true) }
        subject do
          described_class.new(context, requires_authentication: false) do |on|
            on.success { |header, identifier| handler.invoked("SUCCESS", header, identifier) }
            on.failure { |header| handler.invoked("FAILURE", header) }
          end
        end

        it 'requires authentication' do
          expect(context).to receive(:authenticate_user!).and_return(true)
          described_class.new(context)
        end

        it 'requires authorization' do
          allow(subject).to receive(:with_authorization_enforcement).with(:create?, form)
          subject.run(header_id: header_id, identifier: identifier)
          expect(handler).to_not have_received(:invoked)
        end

        context 'when the form submission fails' do
          it 'issues the :failure callback' do
            expect(context.repository).to receive(:submit_assign_a_doi_form).with(form).and_return(false)
            response = subject.run(header_id: header_id, identifier: identifier)
            expect(handler).to have_received(:invoked).with("FAILURE", form)
            expect(response).to eq([:failure, form])
          end
        end

        context 'when the form submission succeeds' do
          it 'issues the :success callback' do
            expect(context.repository).to receive(:submit_assign_a_doi_form).with(form).and_return(true)
            response = subject.run(header_id: header_id, identifier: identifier)
            expect(handler).to have_received(:invoked).with("SUCCESS", header, identifier)
            expect(response).to eq([:success, header, identifier])
          end
        end
      end

      RSpec.describe RequestADoi do
        let(:header) { double }
        let(:header_id) { 1234 }
        let(:attributes) { { key: 'value' } }
        let(:form) { double('Form', submit: true, header: header) }
        let(:context) do
          TestRunnerContext.new(find_header: header, build_request_a_doi_form: form, submit_request_a_doi_form: true)
        end
        let(:handler) { double('Handler', invoked: true) }
        subject do
          described_class.new(context, requires_authentication: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
            on.failure { |a| handler.invoked("FAILURE", a) }
          end
        end

        it 'requires authentication' do
          expect(context).to receive(:authenticate_user!).and_return(true)
          described_class.new(context)
        end

        it 'requires authorization' do
          allow(subject).to receive(:with_authorization_enforcement).with(:create?, form)
          subject.run(header_id: header_id, attributes: attributes)
          expect(handler).to_not have_received(:invoked)
        end

        context 'when the form submission fails' do
          it 'issues the :failure callback' do
            expect(context.repository).to receive(:submit_request_a_doi_form).with(form).and_return(false)
            response = subject.run(header_id: header_id, attributes: attributes)
            expect(handler).to have_received(:invoked).with("FAILURE", form)
            expect(response).to eq([:failure, form])
          end
        end

        context 'when the form submission succeeds' do
          it 'issues the :success callback' do
            expect(context.repository).to receive(:submit_request_a_doi_form).with(form).and_return(true)
            response = subject.run(header_id: header_id, attributes: attributes)
            expect(handler).to have_received(:invoked).with("SUCCESS", header)
            expect(response).to eq([:success, header])
          end
        end
      end
    end
  end
end
