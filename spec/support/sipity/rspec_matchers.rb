module Sipity
  module RSpecMatchers
    class ImplementProcessingFormInterface
      def matches?(actual)
        @actual = actual
        begin
          Forms::ProcessingForm.new(form: actual)
          true
        rescue Exceptions::InterfaceExpectationError => e
          @failure_message = e.message
          false
        end
      end

      def failure_message
        @failure_message || "Expected #{actual} to implement interface asserted by Forms::ProcessingForm"
      end
    end

    def implement_processing_form_interface
      ImplementProcessingFormInterface.new
    end
  end
end
