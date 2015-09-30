require 'spec_helper'
require 'sipity/controllers/processing_action_composer'

module Sipity
  module Controllers
    RSpec.describe ProcessingActionComposer do
      let(:controller) do
        double(
          'Controller',
          params: { processing_action_name: 'hello_world' },
          prepend_view_path: true,
          response_handler_container: double(qualified_const_get: double('Handler')),
          controller_path: 'sipity/controllers/work_submissions',
          run: true
        )
      end

      let(:response_handler) { double(handle_response: true) }
      let(:work_area) { double(slug: 'bug') }
      let(:processing_action_name) { 'hello_world' }

      subject { described_class.new(controller: controller, response_handler: response_handler) }

      its(:processing_action_name) { should eq(processing_action_name) }
      its(:default_response_handler) { should respond_to :handle_response }

      context 'when we receive an :unauthenticated response' do
        it 'will handle unauthenticated' do
          expect(controller).to receive(:run).and_return(:unauthenticated)
          subject.run_and_respond_with_processing_action(work_id: 1)
        end
      end

      it 'will prepend_processing_action_view_path_with' do
        expect(controller).to receive(:prepend_view_path).with(%r{/#{controller.controller_path}/bug\Z})
        subject.prepend_processing_action_view_path_with(slug: 'bug')
      end

      it 'will run and respond with a processing_action' do
        a_response = double(to_work_area: work_area)
        expect(controller).to receive(:run).with(work_id: 1, processing_action_name: processing_action_name).
          and_return([:success, a_response])

        subject.run_and_respond_with_processing_action(work_id: 1)

        expect(response_handler).to have_received(:handle_response).with(
          context: controller,
          handled_response: kind_of(Parameters::HandledResponseParameter),
          container: controller.response_handler_container
        )
      end
    end
  end
end
