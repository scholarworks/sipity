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
    end
  end
end
