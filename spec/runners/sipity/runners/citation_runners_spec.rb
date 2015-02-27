require 'spec_helper'
require 'sipity/runners/citation_runners'

module Sipity
  module Runners
    module CitationRunners
      include RunnersSupport
      RSpec.describe Show do
        let(:work) { double }
        let(:work_id) { 1234 }
        let(:citation_already_assigned) { false }
        let(:context) do
          TestRunnerContext.new(find_work: work, citation_already_assigned?: citation_already_assigned)
        end
        let(:handler) { double(invoked: true) }
        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.citation_not_assigned { |work| handler.invoked("CITATION_NOT_ASSIGNED", work) }
            on.citation_assigned { |work| handler.invoked("CITATION_ASSIGNED", work) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        context 'when a citation is not assigned' do
          let(:citation_already_assigned) { false }
          it 'issues the :citation_not_assigned callback' do
            response = subject.run(work_id: work_id)
            expect(handler).to have_received(:invoked).with("CITATION_NOT_ASSIGNED", work)
            expect(response).to eq([:citation_not_assigned, work])
          end
        end

        context 'when a citation is already assigned' do
          let(:citation_already_assigned) { true }
          it 'issues the :citation_assigned callback' do
            response = subject.run(work_id: work_id)
            expect(handler).to have_received(:invoked).with("CITATION_ASSIGNED", work)
            expect(response).to eq([:citation_assigned, work])
          end
        end
      end

      RSpec.describe New do
        let(:work) { double('Work') }
        let(:work_id) { 1234 }
        let(:form) { double('Form') }
        let(:citation_assigned) { nil }
        let(:context) do
          TestRunnerContext.new(find_work: work, build_assign_a_citation_form: form, citation_already_assigned?: citation_assigned)
        end
        let(:handler) { double('Handler', invoked: true) }
        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.citation_not_assigned { |work| handler.invoked("CITATION_NOT_ASSIGNED", work) }
            on.citation_assigned { |work| handler.invoked("CITATION_ASSIGNED", work) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        context 'when a citation is not assigned' do
          let(:citation_assigned) { false }
          it 'issues the :citation_not_assigned callback with the form' do
            response = subject.run(work_id: work_id)
            expect(handler).to have_received(:invoked).with("CITATION_NOT_ASSIGNED", form)
            expect(response).to eq([:citation_not_assigned, form])
          end
        end

        context 'when a citation is already assigned' do
          let(:citation_assigned) { true }
          it 'issues the :citation_assigned callback with the work' do
            response = subject.run(work_id: work_id)
            expect(handler).to have_received(:invoked).with("CITATION_ASSIGNED", work)
            expect(response).to eq([:citation_assigned, work])
          end
        end
      end

      RSpec.describe Create do
        let(:work) { double }
        let(:work_id) { 1234 }
        let(:attributes) { { key: 'abc:123' } }
        let(:form) { double('Form') }
        let(:context) do
          TestRunnerContext.new(
            current_user: User.new(id: 12), find_work: work, build_assign_a_citation_form: form, submit_assign_a_citation_form: true
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
            expect(form).to receive(:submit).
              with(requested_by: context.current_user).
              and_return(false)
            response = subject.run(work_id: work_id, attributes: attributes)
            expect(handler).to have_received(:invoked).with("FAILURE", form)
            expect(response).to eq([:failure, form])
          end
        end

        context 'when the form submission succeeds' do
          it 'issues the :success callback' do
            expect(form).to receive(:submit).
              with(requested_by: context.current_user).
              and_return(true)
            response = subject.run(work_id: work_id, attributes: attributes)
            expect(handler).to have_received(:invoked).with("SUCCESS", work)
            expect(response).to eq([:success, work])
          end
        end
      end
    end
  end
end
