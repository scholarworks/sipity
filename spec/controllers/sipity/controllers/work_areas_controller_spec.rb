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

      context 'GET #query_action' do
        before { controller.runner = runner }
        let(:processing_action_name) { 'fun_things' }
        it 'will pass along to the response handler' do
          expect(Sipity::ResponseHandlers::WorkAreaHandler::SuccessResponder).to receive(:call).and_call_original

          # I don't want to mess around with all the possible actions
          expect do
            get(
              'query_action',
              work_area_slug: work_area.slug,
              processing_action_name: processing_action_name,
              work_area: { title: 'Hello' }
            )
          end.to raise_error(ActionView::MissingTemplate, %r{sipity/controllers/work_areas/#{processing_action_name}})

          expect(runner).to have_received(:run).with(
            Sipity::Controllers::WorkAreasController,
            work_area_slug: work_area.slug, processing_action_name: processing_action_name, attributes: { 'title' => 'Hello' }
          )

          expect(controller.view_object).to be_present
        end
      end

      context 'POST #command_action' do
        before { controller.runner = runner }
        let(:processing_action_name) { 'fun_things' }
        it 'will pass along to the response handler' do
          expect(Sipity::ResponseHandlers::WorkAreaHandler::SuccessResponder).to receive(:call).and_call_original

          # I don't want to mess around with all the possible actions
          expect do
            post(
              'command_action',
              work_area_slug: work_area.slug,
              processing_action_name: processing_action_name,
              work_area: { title: 'Hello' }
            )
          end.to raise_error(ActionView::MissingTemplate, %r{sipity/controllers/work_areas/#{processing_action_name}})

          expect(runner).to have_received(:run).with(
            Sipity::Controllers::WorkAreasController,
            work_area_slug: work_area.slug, processing_action_name: processing_action_name, attributes: { 'title' => 'Hello' }
          )

          expect(controller.view_object).to be_present
        end
      end
    end
  end
end
