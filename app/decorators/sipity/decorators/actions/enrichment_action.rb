require_relative '../actions'
module Sipity
  module Decorators
    module Actions
      # Actions that are taken that may be required to advance the state; These
      # actions do not advance the state.
      class EnrichmentAction
        def initialize(options = {})
          @action = options.fetch(:action)
          @entity = options.fetch(:entity)
          @view_context = options.fetch(:view_context) { default_view_context }
        end

        attr_reader :action, :entity

        delegate :name, to: :action

        # This action, if it is rendered, is always available.
        def availability_state
          'available'
        end

        def available?
          true
        end

        attr_reader :view_context
        private :view_context

        private

        def default_view_context
          Draper::ViewContext.current
        end
      end
    end
  end
end
