module Sipity
  # A mixin to expose a quick means of guarding an interface.
  module GuardInterfaceExpectation
    private

    def guard_interface_expectation!(input, *expectations, include_all: false)
      expectations.each do |expectation|
        next if input.respond_to?(expectation, include_all)
        fail(Exceptions::InterfaceExpectationError, object: input, expectation: expectation)
      end
    end
  end
end
