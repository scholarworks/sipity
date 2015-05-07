require 'spec_helper'

module Sipity
  module Controllers
    RSpec.describe WorkSubmissionsController, type: :controller do
      let(:work) { Models::Work.new(id: 'abc') }
      let(:status) { :success }
      # REVIEW: It is possible the runner will return a well formed object
      let(:runner) { double('Runner', run: [status, work]) }

      context 'configuration' do
        its(:runner_container) { should eq(Sipity::Runners::WorkSubmissionsRunners) }
        its(:response_handler_container) { should eq(Sipity::ResponseHandlers::WorkSubmissionHandler) }
      end

      context 'GET #query_action' do
        before { controller.runner = runner }
        let(:query_action_name) { 'fun_things' }
        it 'will pass along to the response handler' do
          expect_any_instance_of(Sipity::ResponseHandlers::WorkAreaHandler::SuccessResponse).to receive(:respond).and_call_original

          # I don't want to mess around with all the possible actions
          expect do
            get 'query_action', work_id: work.id, query_action_name: query_action_name, work: { title: 'Hello' }
          end.to raise_error(ActionView::MissingTemplate, %r{sipity/controllers/work_submissions/#{query_action_name}})

          expect(runner).to have_received(:run).with(
            described_class,
            work_id: work.id, processing_action_name: query_action_name, attributes: { 'title' => 'Hello' }
          )

          expect(controller.view_object).to be_present
        end
      end

      context 'POST #command_action' do
        before { controller.runner = runner }
        let(:command_action_name) { 'fun_things' }
        it 'will pass along to the response handler' do
          expect_any_instance_of(Sipity::ResponseHandlers::WorkAreaHandler::SuccessResponse).to receive(:respond).and_call_original

          # I don't want to mess around with all the possible actions
          expect do
            post 'command_action', work_id: work.id, command_action_name: command_action_name, work: { title: 'Hello' }
          end.to raise_error(ActionView::MissingTemplate, %r{sipity/controllers/work_submissions/#{command_action_name}})

          expect(runner).to have_received(:run).with(
            described_class,
            work_id: work.id, processing_action_name: command_action_name, attributes: { 'title' => 'Hello' }
          )

          expect(controller.view_object).to be_present
        end
      end
    end
  end
end
