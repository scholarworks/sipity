require 'spec_helper'
require 'sipity/runners/work_event_trigger_runners'

module Sipity
  module Runners
    module WorkEventTriggerRunners
      include RunnersSupport
      RSpec.describe New do
        let(:work) { double('Work', id: '1234') }
        let(:form) { double('Form') }
        let(:event_name) { 'fandango' }
        let(:context) { TestRunnerContext.new(find_work: work, build_event_trigger_form: form) }
        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.success { |a| context.handler.invoked("SUCCESS", a) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        it 'issues the :success callback' do
          response = subject.run(work_id: work.id, event_name: event_name)
          expect(context.handler).to have_received(:invoked).with("SUCCESS", form)
          expect(response).to eq([:success, form])
        end
      end
    end
  end
end
