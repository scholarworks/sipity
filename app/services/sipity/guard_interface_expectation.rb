require 'active_support/core_ext/array/wrap'

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
      raise(Exceptions::InterfaceExpectationError, object: input, expectations: missing_methods) if missing_methods.present?
    end

    def guard_interface_collaborator_expectations!(input, **keywords)
      errors = []

      keywords.each_pair do |collaborator, method_names|
        Array.wrap(method_names).each do |mname|
          begin
            next if input.public_send(collaborator).public_send(mname)
            errors << { collaborator: collaborator, method_name: mname }
          rescue NoMethodError
            errors << { collaborator: collaborator, method_name: mname }
          end
        end
      end

      raise(Exceptions::InterfaceCollaboratorExpectationError, object: input, collaborator_expectations: errors) if errors.present?
    end
  end
end
