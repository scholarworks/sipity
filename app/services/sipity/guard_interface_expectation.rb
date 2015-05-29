module Sipity
  # A mixin to expose a quick means of guarding an interface.
  module GuardInterfaceExpectation
    private

    def guard_interface_expectation!(input, *expectations, include_all: false)
      missing_methods = []
      Array.wrap(expectations).flatten.each do |expectation|
        next if input.respond_to?(expectation, include_all)
        missing_methods << expectation
      end
      fail(Exceptions::InterfaceExpectationError, object: input, expectations: missing_methods) if missing_methods.present?
    end
  end
end
