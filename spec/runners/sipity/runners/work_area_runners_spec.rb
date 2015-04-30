require 'spec_helper'
require 'sipity/runners/work_area_runners'

module Sipity
  module Runners
    module WorkAreaRunners
      include RunnersSupport
      RSpec.describe Show do
        let(:work_area) { double('Work Area') }
        let(:user) { double('User') }
        let(:context) { TestRunnerContext.new(find_work_area_by: work_area, current_user: user) }
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
          response = subject.run(work_area_slug: 'a_work_area')
          expect(handler).to have_received(:invoked).with("SUCCESS", work_area)
          expect(response).to eq([:success, work_area])
        end
      end

      RSpec.describe SubmissionWindow do
        let(:submission_window) { double('Submission Window') }
        let(:user) { double('User') }
        let(:context) { TestRunnerContext.new(find_submission_window_by: submission_window, current_user: user) }
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
          response = subject.run(work_area_slug: 'a_work_area', submission_window_slug: 'a_submission_window')
          expect(handler).to have_received(:invoked).with("SUCCESS", submission_window)
          expect(response).to eq([:success, submission_window])
        end
      end
    end
  end
end
