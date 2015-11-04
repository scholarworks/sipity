require 'sipity/guard_interface_expectation'

module Sipity
  # :nodoc:
  module Controllers
    # Responsible for composing collaborating behavior on the base controller.
    #
    # This class encapsulates the shared logic of the controller as it handles
    # the response object from a processing action.
    #
    # @todo Extract this from outside of the Controllers module namespace. Its a bit misleading.
    class ProcessingActionComposer
      private_class_method :new

      # @see ProcessingActionComposer#processing_action_name
      def self.build_for_controller(controller:, **keywords)
        ProcessingActionViewPathDelegator.new(
          context: controller,
          runner: controller.method(:run),
          response_handler: keywords.fetch(:response_handler) { Sipity::ResponseHandlers.method(:handle_controller_response) },
          response_handler_container: controller.response_handler_container,
          processing_action_name: keywords.fetch(:processing_action_name) { -> { controller.params.fetch(:processing_action_name) } }
        )
      end

      def self.build_for_command_line(context:, processing_action_name:, runner:, response_handler_container:, **keywords)
        new(
          processing_action_name: processing_action_name,
          context: context,
          runner: runner,
          response_handler_container: response_handler_container,
          response_handler: keywords.fetch(:response_handler) { Sipity::ResponseHandlers.method(:handle_command_line_response) }
        )
      end

      def initialize(context:, processing_action_name:, response_handler_container:, runner:, response_handler:)
        self.context = context
        self.runner = runner
        self.processing_action_name = processing_action_name
        self.response_handler_container = response_handler_container
        self.response_handler = response_handler
      end

      def run_and_respond_with_processing_action(**keywords)
        run_processing_action(**keywords) { |response| handle_response(response) }
      end

      # Why these antics? Because when this object is created using a context as the context, the params object is not entirely set (at
      # least not in test). So I'm adding the ability to provide a callable value.
      #
      # @see ProcessingActionComposer.build_for_controller
      def processing_action_name
        return @processing_action_name.call if @processing_action_name.respond_to?(:call)
        @processing_action_name
      end

      private

      attr_accessor :response_handler_container

      def run_processing_action(**keywords)
        status, object = runner.call(processing_action_name: processing_action_name, **keywords)

        yield(Parameters::HandledResponseParameter.new(status: status, object: object, template: processing_action_name))
      end

      def handle_response(handled_response)
        response_handler.call(
          context: context,
          handled_response: handled_response,
          container: response_handler_container # Note: Controller is passed twice, tighten this up?
        )
      end

      attr_writer :processing_action_name

      attr_accessor :context

      attr_reader :runner

      include GuardInterfaceExpectation
      def runner=(input)
        guard_interface_expectation!(input, :call)
        @runner = input
      end

      attr_reader :response_handler

      def response_handler=(input)
        guard_interface_expectation!(input, :call)
        @response_handler = input
      end
    end

    # Responsible for wrapping controller based view path logic into the mess
    class ProcessingActionViewPathDelegator < ProcessingActionComposer
      public_class_method :new

      def prepend_processing_action_view_path_with(slug:)
        path = build_processing_action_view_path_for(slug: slug)
        context.prepend_view_path(path)
      end

      private

      def run_processing_action(**keywords)
        status, object = runner.call(processing_action_name: processing_action_name, **keywords)
        context.with_authentication_hack_to_remove_warden(status) do
          yield(Parameters::HandledResponseParameter.new(status: status, object: object, template: processing_action_name))
        end
      end

      def context=(input)
        guard_interface_expectation!(input, :prepend_view_path, :controller_path, :with_authentication_hack_to_remove_warden)
        super(input)
      end

      ROOT_VIEW_PATH = Rails.root.join('app/views')

      def build_processing_action_view_path_for(slug:)
        File.join(ROOT_VIEW_PATH, context.controller_path, PowerConverter.convert_to_file_system_safe_file_name(slug))
      end
    end
    private_constant :ProcessingActionViewPathDelegator
  end
end
