require 'spec_helper'
require 'sipity/runners/submission_window_runners'

module Sipity
  module Runners
    module SubmissionWindowRunners
      include RunnersSupport
      RSpec.describe Show do
        let(:submission_window) { double('Submission Window') }
        let(:user) { double('User') }
        let(:context) { TestRunnerContext.new(find_submission_window_by: submission_window, current_user: user) }
        let(:handler) { double(invoked: true) }

        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
          end
        end

        its(:action_name) { should eq(:show?) }

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        it 'issues the :success callback' do
          response = subject.run(work_area_slug: 'a_work_area', submission_window_slug: 'a_submission_window')
          expect(handler).to have_received(:invoked).with("SUCCESS", submission_window)
          expect(response).to eq([:success, submission_window])
        end
      end

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
          expect(form).to receive(:submit).with(requested_by: user).and_return(true)
          response = subject.run(
            work_area_slug: 'a_work_area', submission_window_slug: 'a_submission_window', processing_action_name: 'a_funny'
          )
          expect(handler).to have_received(:invoked).with("SUCCESS", submission_window)
          expect(response).to eq([:success, submission_window])
        end

        it 'issues the :failure callback when form fails to submit' do
          expect(form).to receive(:submit).with(requested_by: user).and_return(false)
          response = subject.run(
            work_area_slug: 'a_work_area', submission_window_slug: 'a_submission_window', processing_action_name: 'a_funny'
          )
          expect(handler).to have_received(:invoked).with("FAILURE", form)
          expect(response).to eq([:failure, form])
        end
      end

    end
  end
end
