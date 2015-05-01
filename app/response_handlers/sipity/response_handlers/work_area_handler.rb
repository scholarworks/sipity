module Sipity
  module ResponseHandlers
    # This is an Experimental module and concept
    module WorkAreaHandler
      # Responsible for handling a :success-ful action
      class SuccessResponse
        def self.respond(**keywords)
          new(**keywords).respond
        end

        attr_reader :context, :handled_response, :template
        def initialize(context:, handled_response:, template:)
          self.context = context
          self.handled_response = handled_response
          self.template = template
          prepare_context_for_response
        end

        def respond
          # Consider yielding options for configuration
          context.render(template: template)
        end

        private

        attr_writer :template

        def prepare_context_for_response
          # Wouldn't it be great if we had proper View objects in Rails? Instead
          # of this crazy copy instance variables from the controller to the
          # template (aka 'ActionView') layer.
          context.view_object = handled_response.object
        end

        def context=(input)
          guard_interface_expectation!(input, :view_object=, :render)
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
end
