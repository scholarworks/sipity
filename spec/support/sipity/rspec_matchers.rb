require 'contracts'
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

    # Does the licensee adhear to the given contract?
    class ContractuallyHonorMatcher
      def initialize(contract)
        @contract = contract
      end

      def matches?(licensee)
        @licensee = licensee
        Contract.valid?(@licensee, @contract)
      end

      def description
        "expected to honor the #{@contract.inspect} contract"
      end

      def failure_message
        "expected #{@licensee} to honor #{@contract.inspect} contract"
      end
    end

    def contractually_honor(contract)
      ContractuallyHonorMatcher.new(contract)
    end
  end
end
