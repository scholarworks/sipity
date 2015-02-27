require 'spec_helper'
require 'sipity/runners/work_enrichment_runners'

module Sipity
  module Runners
    module WorkEnrichmentRunners
      include RunnersSupport
      RSpec.describe Edit do
        let(:work) { double('Work', id: work_id) }
        let(:form) { double('Form') }
        let(:work_id) { 1234 }
        let(:user) { double('User') }
        let(:enrichment_type) { 'fandango' }
        let(:handler) { double(invoked: true) }
        let(:context) do
          TestRunnerContext.new(find_work: work, build_enrichment_form: form)
        end
        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        it 'issues the :success callback' do
          response = subject.run(work_id: work_id, enrichment_type: enrichment_type)
          expect(handler).to have_received(:invoked).with("SUCCESS", form)
          expect(response).to eq([:success, form])
        end
      end

      RSpec.describe Update do
        let(:work) { double('Work', id: 1234) }
        let(:form) { double('Form') }
        let(:user) { double('User') }
        let(:enrichment_type) { 'fandango' }
        let(:attributes) { { 'title' => 'match' } }
        let(:handler) { double(invoked: true) }
        let(:context) do
          TestRunnerContext.new(find_work: work, build_enrichment_form: form)
        end
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
            response = subject.run(work_id: work.id, enrichment_type: enrichment_type, attributes: attributes)
            expect(handler).to have_received(:invoked).with("FAILURE", form)
            expect(response).to eq([:failure, form])
          end
        end

        context 'when the form submission succeeds' do
          it 'issues the :success callback' do
            expect(form).to receive(:submit).
              with(requested_by: context.current_user).
              and_return(true)
            response = subject.run(work_id: work.id, enrichment_type: enrichment_type, attributes: attributes)
            expect(handler).to have_received(:invoked).with("SUCCESS", work)
            expect(response).to eq([:success, work])
          end
        end
      end
    end
  end
end
