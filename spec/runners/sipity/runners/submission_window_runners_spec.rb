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
    end
  end
end
