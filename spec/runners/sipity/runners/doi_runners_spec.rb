require 'spec_helper'
require 'sipity/runners/doi_runners'

module Sipity
  module Runners
    module DoiRunners
      include RunnersSupport
      RSpec.describe Show do
        let(:sip) { double }
        let(:sip_id) { 1234 }
        let(:context) do
          TestRunnerContext.new(find_sip: sip, doi_already_assigned?: false, doi_request_is_pending?: false)
        end
        let(:handler) { double(invoked: true) }
        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.doi_already_assigned { |sip| handler.invoked("DOI_ALREADY_ASSIGNED", sip) }
            on.doi_not_assigned { |sip| handler.invoked("DOI_NOT_ASSIGNED", sip) }
            on.doi_request_is_pending { |sip| handler.invoked("DOI_REQUEST_IS_PENDING", sip) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        context 'when a DOI is assigned' do
          it 'issues the :doi_already_assigned callback' do
            expect(context.repository).to receive(:doi_already_assigned?).and_return true
            response = subject.run(sip_id: sip_id)
            expect(handler).to have_received(:invoked).with("DOI_ALREADY_ASSIGNED", sip)
            expect(response).to eq([:doi_already_assigned, sip])
          end
        end

        context 'when a DOI is not assigned' do
          it 'issues the :doi_not_assigned callback' do
            response = subject.run(sip_id: sip_id)
            expect(handler).to have_received(:invoked).with("DOI_NOT_ASSIGNED", sip)
            expect(response).to eq([:doi_not_assigned, sip])
          end
        end

        context 'when a DOI request has been made but not yet completed' do
          it 'issues the :doi_request_is_pending callback' do
            expect(context.repository).to receive(:doi_request_is_pending?).and_return(true)
            response = subject.run(sip_id: sip_id)
            expect(handler).to have_received(:invoked).with("DOI_REQUEST_IS_PENDING", sip)
            expect(response).to eq([:doi_request_is_pending, sip])
          end
        end
      end

      RSpec.describe AssignADoi do
        let(:sip) { double }
        let(:sip_id) { 1234 }
        let(:identifier) { 'abc:123' }
        let(:form) { double('Form', submit: true, identifier: identifier, sip: sip, identifier_key: 'key') }
        let(:context) do
          TestRunnerContext.new(
            current_user: User.new(id: 12), find_sip: sip, build_assign_a_doi_form: form, submit_assign_a_doi_form: true
          )
        end
        let(:handler) { double('Handler', invoked: true) }
        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.success { |sip, identifier| handler.invoked("SUCCESS", sip, identifier) }
            on.failure { |sip| handler.invoked("FAILURE", sip) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        context 'when the form submission fails' do
          it 'issues the :failure callback' do
            expect(context.repository).
              to receive(:submit_assign_a_doi_form).with(form, requested_by: context.current_user).and_return(false)
            response = subject.run(sip_id: sip_id, identifier: identifier)
            expect(handler).to have_received(:invoked).with("FAILURE", form)
            expect(response).to eq([:failure, form])
          end
        end

        context 'when the form submission succeeds' do
          it 'issues the :success callback' do
            expect(context.repository).
              to receive(:submit_assign_a_doi_form).with(form, requested_by: context.current_user).and_return(true)
            response = subject.run(sip_id: sip_id, identifier: identifier)
            expect(handler).to have_received(:invoked).with("SUCCESS", sip, identifier)
            expect(response).to eq([:success, sip, identifier])
          end
        end
      end

      RSpec.describe RequestADoi do
        let(:sip) { double }
        let(:sip_id) { 1234 }
        let(:attributes) { { key: 'value' } }
        let(:form) { double('Form', submit: true, sip: sip) }
        let(:context) do
          TestRunnerContext.new(
            current_user: User.new(id: 12), find_sip: sip, build_request_a_doi_form: form, submit_request_a_doi_form: true
          )
        end
        let(:handler) { double('Handler', invoked: true) }
        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
            on.failure { |a| handler.invoked("FAILURE", a) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        context 'when the form submission fails' do
          it 'issues the :failure callback' do
            expect(context.repository).
              to receive(:submit_request_a_doi_form).with(form, requested_by: context.current_user).and_return(false)
            response = subject.run(sip_id: sip_id, attributes: attributes)
            expect(handler).to have_received(:invoked).with("FAILURE", form)
            expect(response).to eq([:failure, form])
          end
        end

        context 'when the form submission succeeds' do
          it 'issues the :success callback' do
            expect(context.repository).
              to receive(:submit_request_a_doi_form).with(form, requested_by: context.current_user).and_return(true)
            response = subject.run(sip_id: sip_id, attributes: attributes)
            expect(handler).to have_received(:invoked).with("SUCCESS", sip)
            expect(response).to eq([:success, sip])
          end
        end
      end
    end
  end
end
