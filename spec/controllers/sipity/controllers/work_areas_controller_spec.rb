require 'spec_helper'

module Sipity
  module Controllers
    RSpec.describe WorkAreasController, type: :controller do
      let(:work_area) { Models::WorkArea.new(slug: 'work-area') }
      let(:status) { :success }
      # REVIEW: It is possible the runner will return a well formed object
      let(:runner) { double('Runner', run: [status, work_area]) }
      context 'configuration' do
        its(:runner_container) { should eq(Sipity::Runners::WorkAreaRunners) }
        its(:response_handler_container) { should eq(Sipity::ResponseHandlers::WorkAreaHandler) }
      end

      context 'GET #show' do
        before { controller.runner = runner }
        it 'will pass along to the response handler' do
          expect_any_instance_of(Sipity::ResponseHandlers::WorkAreaHandler::SuccessResponse).to receive(:respond)
          get 'show', work_area_slug: work_area.slug

          expect(controller.view_object).to be_present
        end
      end

      context 'GET #submission_window' do
        let(:submission_window) { Models::SubmissionWindow.new(slug: 'submission-window', work_area: work_area) }
        let(:runner) { double('Runner', run: [status, submission_window]) }
        before { controller.runner = runner }
        it 'will pass along to the response handler' do
          expect_any_instance_of(Sipity::ResponseHandlers::WorkAreaHandler::SuccessResponse).to receive(:respond)
          get 'submission_window', work_area_slug: work_area.slug, submission_window_slug: submission_window.slug

          expect(controller.view_object).to be_present
        end
      end
    end
  end
end
