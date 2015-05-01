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

    def handle_response(context:, handled_response:, container:, template:)
      response_handler = build_response_handler(container: container, handled_response_status: handled_response.status)
      response_handler.respond(context: context, handled_response: handled_response, template: template)
    end

    def build_response_handler(container:, handled_response_status:)
      container.qualified_const_get("#{handled_response_status.to_s.classify}Response")
    end
  end
end
