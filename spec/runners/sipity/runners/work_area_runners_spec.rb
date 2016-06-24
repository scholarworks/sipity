require "rails_helper"
require 'sipity/runners/work_area_runners'
require 'sipity/runners/work_area_runners'

module Sipity
  module Runners
    module WorkAreaRunners
      include RunnersSupport

      RSpec.describe QueryAction do
        let(:work_area) { double('Work Area') }
        let(:user) { double('User') }
        let(:form) { double('Form') }
        let(:processing_action_name) { 'fun_things' }
        let(:context) do
          TestRunnerContext.new(find_work_area_by: work_area, current_user: user, build_work_area_processing_action_form: form)
        end
        let(:handler) { double(invoked: true) }

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
          response = subject.run(work_area_slug: 'a_work_area', processing_action_name: processing_action_name, attributes: double)
          expect(handler).to have_received(:invoked).with("SUCCESS", form)
          expect(response).to eq([:success, form])
        end
      end

      RSpec.describe CommandAction do
        let(:work_area) { double('Work Area') }
        let(:user) { double('User') }
        let(:form) { double('Form') }
        let(:processing_action_name) { 'fun_things' }
        let(:context) do
          TestRunnerContext.new(find_work_area_by: work_area, current_user: user, build_work_area_processing_action_form: form)
        end
        let(:handler) { double(invoked: true) }

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

        it 'issues the :success callback when form is submitted' do
          expect(form).to receive(:submit).and_return(true)
          response = subject.run(work_area_slug: 'a_work_area', processing_action_name: processing_action_name, attributes: double)
          expect(handler).to have_received(:invoked).with("SUCCESS", work_area)
          expect(response).to eq([:success, work_area])
        end

        it 'issues the :failure callback when form fails to submit' do
          expect(form).to receive(:submit).and_return(false)
          response = subject.run(work_area_slug: 'a_work_area', processing_action_name: processing_action_name, attributes: double)
          expect(handler).to have_received(:invoked).with("FAILURE", form)
          expect(response).to eq([:failure, form])
        end
      end
    end
  end
end
