require 'sipity/guard_interface_expectation'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Controllers
    # Responsible for presenting the debug view of a Role
    class DebugRolePresenter < Curly::Presenter
      presents :debug_role

      delegate :name, :to_processing_entity, :repository, to: :debug_role
      delegate :id, :model_name, to: :debug_role, prefix: :role

      def initialize(context, options = {})
        super
        guard!
      end

      def debug_actors
        Array.wrap(repository.scope_actors_associated_with_entity_and_role(entity: to_processing_entity, role: debug_role))
      end

      private

      attr_reader :debug_role

      include GuardInterfaceExpectation
      def guard!
        guard_interface_expectation!(debug_role, :to_processing_entity, :name, :id, :repository)
      end
    end
  end
end
