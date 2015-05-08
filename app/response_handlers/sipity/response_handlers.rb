module Sipity
  # ResponseHandlers are a means of encapsulating how we respond to an action's
  # response. Action responses should implement the interface of the
  # HandledResponseParameter.
  #
  # This is experimental; After conversations with @terrellt I wanted to
  # eliminate the callbacks of the runners. They were helpful to convey what was
  # happening. I believe the callbacks have reduced some of the complexities
  # of controller testing. There was room for more, and I hope that is made
  # clear through this experimentation.
  #
  # @see Sipity::Parameters::HandledResponseParameter
  # @see Sipity::Runners::BaseRunner
  module ResponseHandlers
    module_function

    # TODO: Remove the template as it can be packed into the handled response
    def handle_response(context:, handled_response:, container:, template:, handler: DefaultHandler)
      responder = build_responder(container: container, handled_response_status: handled_response.status)
      handler.respond(context: context, handled_response: handled_response, template: template, responder: responder)
    end

    def build_responder(container:, handled_response_status:)
      container.qualified_const_get("#{handled_response_status.to_s.classify}Responder")
    end

    # The default response handler. It makes sure things are well composed,
    # guarding the interface of collaborating objects.
    class DefaultHandler
      def self.respond(**keywords)
        new(**keywords).respond
      end

      attr_reader :context, :handled_response, :template
      def initialize(context:, handled_response:, template:, responder: default_responder)
        self.context = context
        self.handled_response = handled_response
        self.template = template
        self.responder = responder
        prepare_context_for_response
      end

      def respond
        responder.call(handler: self)
      end

      delegate :render, :redirect_to, to: :context
      delegate :object, to: :handled_response, prefix: :response

      private

      attr_accessor :responder
      attr_writer :template

      def default_responder
        -> (handler:) { handler.render(template: handler.template) }
      end

      def prepare_context_for_response
        # Wouldn't it be great if we had proper View objects in Rails? Instead
        # of this crazy copy instance variables from the controller to the
        # template (aka 'ActionView') layer.
        context.view_object = handled_response.object
      end

      def context=(input)
        guard_interface_expectation!(input, :view_object=, :render, :redirect_to)
        @context = input
      end

      def handled_response=(input)
        guard_interface_expectation!(input, :object)
        @handled_response = input
      end

      # TODO: Extract this concept?
      def guard_interface_expectation!(input, *expectations)
        expectations.each do |expectation|
          fail(Exceptions::InterfaceExpectationError, object: input, expectation: expectation) unless input.respond_to?(expectation)
        end
      end
    end
  end
end
