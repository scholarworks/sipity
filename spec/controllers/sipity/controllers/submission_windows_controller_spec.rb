require 'spec_helper'

module Sipity
  module Controllers
    RSpec.describe SubmissionWindowsController, type: :controller do
      let(:submission_window) { Models::WorkArea.new(slug: 'window') }
      let(:status) { :success }
      # REVIEW: It is possible the runner will return a well formed object
      let(:runner) { double('Runner', run: [status, submission_window]) }
      context 'configuration' do
        its(:runner_container) { should eq(Runners::SubmissionWindowRunners) }
        its(:response_handler_container) { should eq(ResponseHandlers::SubmissionWindowHandler) }
      end

      context 'GET #show' do
        before { controller.runner = runner }
        it 'will pass along to the response handler' do
          expect_any_instance_of(ResponseHandlers::SubmissionWindowHandler::SuccessResponse).to receive(:respond).and_call_original
          get 'show', work_area_slug: 'work-area', submission_window_slug: submission_window.slug

          expect(controller.view_object).to be_present
        end
      end
    end
  end
end
