module Sipity
  module Parameters
    # Responsible for defining the mapping interface between the Runners
    # and the ResponseHandlers.
    class HandledResponseParameter
      def initialize(object:, status:)
        self.object = object
        self.status = status
      end

      # @!attribute [r] object
      #   The thing that will be used to generate the response output; In Rails
      #   analogue, this is the instance variable that we will send to the view.
      #   @return [Object]
      attr_reader :object
      #
      # @!attribute [r] status
      #   A symbolic response from the runner. It is the response handler's job
      #   to translate the runner's status to a client meaningful response
      #   status; In Rails analogue, translating the :success status of a runner
      #   might mean rendering a 200 status (if we found something), or a 302
      #   status if we created something.
      #   @return [Symbol]
      attr_reader :status

      private

      attr_writer :object

      def status=(input)
        fail Exceptions::InvalidHandledResponseStatus, input unless input.is_a?(Symbol)
        @status = input
      end
    end
  end
end
