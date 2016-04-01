require 'spec_helper'
require 'sipity/controllers/processing_action_composer'

module Sipity
  module Controllers
    RSpec.describe ProcessingActionComposer do
      let(:a_response) { double(to_work_area: work_area, errors: []) }
      let(:work_area) { double(slug: 'bug') }
      let(:response_handler) { double(call: true) }
      let(:processing_action_name) { 'hello_world' }

      context '.build_for_command_line' do
        let(:command_line_context) { double('Command Line Context') }
        let(:runner) { double('Runner', call: true) }
        let(:response_handler_container) { double }
        subject do
          described_class.build_for_command_line(
            response_handler: response_handler, context: command_line_context, processing_action_name: processing_action_name,
            response_handler_container: response_handler_container, runner: runner
          )
        end

        context 'with default build options' do
          subject do
            described_class.build_for_command_line(
              response_handler_container: response_handler_container, runner: runner, context: command_line_context,
              processing_action_name: processing_action_name
            )
          end
          its(:response_handler) { should respond_to(:call) }
        end

        it { is_expected.not_to respond_to(:prepend_processing_action_view_path_with) }

        it 'will expose #run_and_respond_with_processing_action' do
          expect(runner).to receive(:call).with(work_id: 1, processing_action_name: processing_action_name).
            and_return([:success, a_response])

          subject.run_and_respond_with_processing_action(work_id: 1)

          expect(response_handler).to have_received(:call).with(
            handled_response: kind_of(Parameters::HandledResponseParameter), context: command_line_context,
            container: response_handler_container
          )

        end
      end

      context '.build_for_controller' do
        let(:controller) do
          double(
            params: { processing_action_name: 'hello_world' },
            prepend_view_path: true,
            response_handler_container: double,
            controller_path: 'sipity/controllers/work_submissions',
            run: true
          )
        end

        subject { described_class.build_for_controller(controller: controller, response_handler: response_handler) }

        its(:processing_action_name) { should eq(processing_action_name) }
        it { should respond_to(:processing_action_name) }

        context 'with default build options' do
          subject { described_class.build_for_controller(controller: controller, processing_action_name: 'york') }
          its(:response_handler) { should respond_to(:call) }
        end

        it 'will allow a specific processing action name to be provided' do
          subject = described_class.build_for_controller(
            controller: controller, response_handler: response_handler, processing_action_name: 'york'
          )
          expect(subject.processing_action_name).to eq('york')
        end

        it 'will prepend_processing_action_view_path_with' do
          expect(controller).to receive(:prepend_view_path).with(%r{/#{controller.controller_path}/bug\Z})
          subject.prepend_processing_action_view_path_with(slug: 'bug')
        end

        it 'will run and respond with a processing_action' do
          expect(controller).to receive(:run).with(work_id: 1, processing_action_name: processing_action_name).
            and_return([:success, a_response])

          subject.run_and_respond_with_processing_action(work_id: 1)

          expect(response_handler).to have_received(:call).with(
            context: controller,
            handled_response: kind_of(Parameters::HandledResponseParameter),
            container: controller.response_handler_container
          )
        end
      end
    end
  end
end
