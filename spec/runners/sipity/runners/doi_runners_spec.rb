require 'spec_helper'
require 'sipity/runners/doi_runners'

module Sipity
  module Runners
    module DoiRunners
      include RunnersSupport
      RSpec.describe Show do
        let(:work) { double }
        let(:work_id) { 1234 }
        let(:context) do
          TestRunnerContext.new(find_work: work, doi_already_assigned?: false, doi_request_is_pending?: false)
        end
        let(:handler) { double(invoked: true) }
        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.doi_already_assigned { |work| handler.invoked("DOI_ALREADY_ASSIGNED", work) }
            on.doi_not_assigned { |work| handler.invoked("DOI_NOT_ASSIGNED", work) }
            on.doi_request_is_pending { |work| handler.invoked("DOI_REQUEST_IS_PENDING", work) }
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
            response = subject.run(work_id: work_id)
            expect(handler).to have_received(:invoked).with("DOI_ALREADY_ASSIGNED", work)
            expect(response).to eq([:doi_already_assigned, work])
          end
        end

        context 'when a DOI is not assigned' do
          it 'issues the :doi_not_assigned callback' do
            response = subject.run(work_id: work_id)
            expect(handler).to have_received(:invoked).with("DOI_NOT_ASSIGNED", work)
            expect(response).to eq([:doi_not_assigned, work])
          end
        end

        context 'when a DOI request has been made but not yet completed' do
          it 'issues the :doi_request_is_pending callback' do
            expect(context.repository).to receive(:doi_request_is_pending?).and_return(true)
            response = subject.run(work_id: work_id)
            expect(handler).to have_received(:invoked).with("DOI_REQUEST_IS_PENDING", work)
            expect(response).to eq([:doi_request_is_pending, work])
          end
        end
      end

      RSpec.describe AssignADoi do
        let(:work) { double }
        let(:work_id) { 1234 }
        let(:identifier) { 'abc:123' }
        let(:form) { double('Form', submit: true, identifier: identifier, work: work, identifier_key: 'key') }
        let(:context) do
          TestRunnerContext.new(
            current_user: User.new(id: 12), find_work: work, build_assign_a_doi_form: form, submit_assign_a_doi_form: true
          )
        end
        let(:handler) { double('Handler', invoked: true) }
        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.success { |work, identifier| handler.invoked("SUCCESS", work, identifier) }
            on.failure { |work| handler.invoked("FAILURE", work) }
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
            response = subject.run(work_id: work_id, identifier: identifier)
            expect(handler).to have_received(:invoked).with("FAILURE", form)
            expect(response).to eq([:failure, form])
          end
        end

        context 'when the form submission succeeds' do
          it 'issues the :success callback' do
            expect(context.repository).
              to receive(:submit_assign_a_doi_form).with(form, requested_by: context.current_user).and_return(true)
            response = subject.run(work_id: work_id, identifier: identifier)
            expect(handler).to have_received(:invoked).with("SUCCESS", work, identifier)
            expect(response).to eq([:success, work, identifier])
          end
        end
      end

      RSpec.describe RequestADoi do
        let(:work) { double }
        let(:work_id) { 1234 }
        let(:attributes) { { key: 'value' } }
        let(:form) { double('Form', submit: true, work: work) }
        let(:context) do
          TestRunnerContext.new(
            current_user: User.new(id: 12), find_work: work, build_request_a_doi_form: form, submit_request_a_doi_form: true
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
            response = subject.run(work_id: work_id, attributes: attributes)
            expect(handler).to have_received(:invoked).with("FAILURE", form)
            expect(response).to eq([:failure, form])
          end
        end

        context 'when the form submission succeeds' do
          it 'issues the :success callback' do
            expect(context.repository).
              to receive(:submit_request_a_doi_form).with(form, requested_by: context.current_user).and_return(true)
            response = subject.run(work_id: work_id, attributes: attributes)
            expect(handler).to have_received(:invoked).with("SUCCESS", work)
            expect(response).to eq([:success, work])
          end
        end
      end
    end
  end
end
