require 'spec_helper'

module Sipity
  module Controllers
    RSpec.describe SubmissionWindowsController, type: :controller do
      let(:submission_window) { Models::SubmissionWindow.new(slug: 'start', work_area: work_area) }
      let(:work_area) { Models::WorkArea.new(slug: 'etd') }
      let(:status) { :success }
      # REVIEW: It is possible the runner will return a well formed object
      let(:runner) { double('Runner', run: [status, submission_window]) }
      context 'configuration' do
        its(:runner_container) { should eq(Runners::SubmissionWindowRunners) }
        its(:response_handler_container) { should eq(ResponseHandlers::SubmissionWindowHandler) }
      end

      context 'GET #query_action' do
        before { controller.runner = runner }
        let(:query_action_name) { 'fun_things' }
        it 'will pass along to the response handler' do
          expect_any_instance_of(Sipity::ResponseHandlers::SubmissionWindowHandler::SuccessResponse).to receive(:respond).and_call_original

          # I don't want to mess around with all the possible actions
          expect do
            get(
              'query_action',
              work_area_slug: work_area.slug,
              submission_window_slug: submission_window.slug,
              query_action_name: query_action_name,
              submission_window: { title: 'Hello' }
            )
          end.to raise_error(ActionView::MissingTemplate, %r{sipity/controllers/submission_windows/#{query_action_name}})

          expect(runner).to have_received(:run).with(
            Sipity::Controllers::SubmissionWindowsController,
            work_area_slug: work_area.slug,
            submission_window_slug: submission_window.slug,
            processing_action_name: query_action_name,
            attributes: { 'title' => 'Hello' }
          )

          expect(controller.view_object).to be_present
        end
      end

      context 'POST #command_action' do
        before { controller.runner = runner }
        let(:command_action_name) { 'fun_things' }
        it 'will pass along to the response handler' do
          expect_any_instance_of(Sipity::ResponseHandlers::SubmissionWindowHandler::SuccessResponse).to receive(:respond).and_call_original

          # I don't want to mess around with all the possible actions
          expect do
            post(
              'command_action',
              work_area_slug: work_area.slug,
              submission_window_slug: submission_window.slug,
              command_action_name: command_action_name,
              submission_window: { title: 'Hello' }
            )
          end.to raise_error(ActionView::MissingTemplate, %r{sipity/controllers/submission_windows/#{command_action_name}})

          expect(runner).to have_received(:run).with(
            Sipity::Controllers::SubmissionWindowsController,
            work_area_slug: work_area.slug,
            submission_window_slug: submission_window.slug,
            processing_action_name: command_action_name,
            attributes: { 'title' => 'Hello' }
          )

          expect(controller.view_object).to be_present
        end
      end
    end
  end
end
