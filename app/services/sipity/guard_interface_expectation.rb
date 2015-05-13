module Sipity
  # A mixin to expose a quick means of guarding an interface.
  module GuardInterfaceExpectation
    private

    def guard_interface_expectation!(input, *expectations)
      expectations.each do |expectation|
        fail(Exceptions::InterfaceExpectationError, object: input, expectation: expectation) unless input.respond_to?(expectation)
      end
    end
  end
end
