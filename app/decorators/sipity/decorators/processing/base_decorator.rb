module Sipity
  module Decorators
    module Processing
      # Responsible for helping with the rendering of an action, and its
      # relative availability.
      class BaseDecorator
        ACTION_AVAILABLE = 'available'
        ACTION_UNAVAILABLE = 'unavailable'

        def initialize(options = {})
          @action = options.fetch(:action)
          @entity = options.fetch(:entity)
        end

        attr_reader :action, :entity

        delegate :name, :action_type, to: :action

        # This action, if it is rendered, is always available.
        def availability_state
          'available'
        end

        def available?
          availability_state == ACTION_AVAILABLE
        end

        def path
          view_context.enrich_work_path(entity, name)
        end

        private

        def view_context
          Draper::ViewContext.current
        end
      end
    end
  end
end
