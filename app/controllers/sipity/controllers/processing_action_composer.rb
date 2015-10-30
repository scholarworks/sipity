require 'sipity/guard_interface_expectation'

module Sipity
  module Controllers
    # Responsible for composing collaborating behavior on the base controller.
    #
    # This class encapsulates the shared logic of the controller as it handles
    # the response object from a processing action.
    class ProcessingActionComposer
      private_class_method :new

      def self.build_for_controller(controller:, **keywords)
        new(controller: controller, **keywords)
      end

      def initialize(controller:, response_handler: default_response_handler)
        self.controller = controller
        self.response_handler = response_handler
      end

      def prepend_processing_action_view_path_with(slug:)
        path = build_processing_action_view_path_for(slug: slug)
        controller.prepend_view_path(path)
      end

      def run_and_respond_with_processing_action(**keywords)
        handle_response(run_processing_action(**keywords))
      end

      private

      def run_processing_action(**keywords)
        status, object = controller.run(processing_action_name: processing_action_name, **keywords)
        Parameters::HandledResponseParameter.new(status: status, object: object, template: processing_action_name)
      end

      def handle_response(handled_response)
        response_handler.handle_response(
          context: controller,
          handled_response: handled_response,
          container: controller.response_handler_container # Note: Controller is passed twice, tighten this up?
        )
      end

      def processing_action_name
        controller.params.fetch(:processing_action_name)
      end

      attr_reader :controller

      include GuardInterfaceExpectation
      def controller=(input)
        guard_interface_expectation!(input, :prepend_view_path, :params, :run, :response_handler_container, :controller_path)
        @controller = input
      end

      ROOT_VIEW_PATH = Rails.root.join('app/views')

      def build_processing_action_view_path_for(slug:)
        File.join(ROOT_VIEW_PATH, controller.controller_path, PowerConverter.convert_to_file_system_safe_file_name(slug))
      end

      attr_reader :response_handler

      def response_handler=(input)
        guard_interface_expectation!(input, :handle_response)
        @response_handler = input
      end

      def default_response_handler
        Sipity::ResponseHandlers
      end
    end
  end
end
