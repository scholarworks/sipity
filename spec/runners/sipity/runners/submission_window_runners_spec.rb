require "rails_helper"
require 'sipity/runners/submission_window_runners'
require 'sipity/runners/submission_window_runners'

module Sipity
  module Runners
    module SubmissionWindowRunners
      include RunnersSupport
      RSpec.describe QueryAction do
        let(:submission_window) { double('Submission Window') }
        let(:form) { double('Form') }
        let(:user) { double('User') }
        let(:context) do
          TestRunnerContext.new(
            find_submission_window_by: submission_window,
            current_user: user,
            build_submission_window_processing_action_form: form
          )
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
          response = subject.run(
            work_area_slug: 'a_work_area', submission_window_slug: 'a_submission_window', processing_action_name: 'a_funny'
          )
          expect(handler).to have_received(:invoked).with("SUCCESS", form)
          expect(response).to eq([:success, form])
        end
      end

      RSpec.describe CommandAction do
        let(:submission_window) { double('Submission Window') }
        let(:form) { double('Form') }
        let(:user) { double('User') }
        let(:context) do
          TestRunnerContext.new(
            find_submission_window_by: submission_window,
            current_user: user,
            build_submission_window_processing_action_form: form
          )
        end
        let(:handler) { double(invoked: true) }

        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.submit_success { |a| handler.invoked("SUCCESS", a) }
            on.submit_failure { |a| handler.invoked("FAILURE", a) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        it 'issues the :submit_success callback when form is submitted' do
          expect(form).to receive(:submit).and_return(submission_window)
          response = subject.run(
            work_area_slug: 'a_work_area', submission_window_slug: 'a_submission_window', processing_action_name: 'a_funny'
          )
          expect(handler).to have_received(:invoked).with("SUCCESS", submission_window)
          expect(response).to eq([:submit_success, submission_window])
        end

        it 'issues the :submit_failure callback when form fails to submit' do
          expect(form).to receive(:submit).and_return(false)
          response = subject.run(
            work_area_slug: 'a_work_area', submission_window_slug: 'a_submission_window', processing_action_name: 'a_funny'
          )
          expect(handler).to have_received(:invoked).with("FAILURE", form)
          expect(response).to eq([:submit_failure, form])
        end
      end
    end
  end
end
