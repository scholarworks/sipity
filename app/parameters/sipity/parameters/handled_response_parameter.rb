require 'power_converter'
require 'sipity/exceptions'
require 'sipity/guard_interface_expectation'
require 'forwardable'

module Sipity
  module Parameters
    # Responsible for defining the mapping interface between the Runners
    # and the ResponseHandlers.
    class HandledResponseParameter
      def initialize(object:, status:, template:)
        self.object = object
        self.status = status
        self.template = template
      end

      # @!attribute [r] object
      #   The thing that will be used to generate the response output; In Rails
      #   analogue, this is the instance variable that we will send to the view.
      #   @return [Object]
      attr_reader :object

      extend Forwardable
      # @!attribute [r] errors
      #   Any errors associated with the handled response
      #   @return [Enumerable]
      def_delegator :object, :errors

      #
      # @!attribute [r] status
      #   A symbolic response from the runner. It is the response handler's job
      #   to translate the runner's status to a client meaningful response
      #   status; In Rails analogue, translating the :success status of a runner
      #   might mean rendering a 200 status (if we found something), or a 302
      #   status if we created something.
      #   @return [Symbol]
      attr_reader :status

      # The name of the template that we "may" render.
      # @return [Object]
      # @note I chose :template instead of :template_name as Rails convention
      #   for rendering a named template is `render template: 'show'`
      def template
        if object.respond_to?(:template)
          object.template
        else
          @template
        end
      end

      # Inject these view path slugs into the rendering sequence. In doing so we
      # are able to use specific partials and presenters but fallback on more
      # generic presenters.
      #
      # @note Order is very important; The values yielded are with increased specificity.
      def with_each_additional_view_path_slug
        yield('') # Can this be deprecated?
        yield('core') # I want to move things up to core
        yield(work_area.slug) # Important if we want to leverage a specific template
      end

      attr_reader :work_area

      private

      attr_writer :template

      def status=(input)
        raise Exceptions::InvalidHandledResponseStatus, input unless input.is_a?(Symbol)
        @status = input
      end

      include Sipity::GuardInterfaceExpectation
      def object=(input)
        # TODO: Refactor to include Contracts gem
        guard_interface_expectation!(input, :errors)
        @work_area = PowerConverter.convert_to_work_area(input)
        @object = input
      end
    end
  end
end
