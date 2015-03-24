module Sipity
  module Decorators
    module Processing
      # Responsible for helping with the rendering of an action, and its
      # relative availability.
      class BaseDecorator
        ACTION_AVAILABLE = 'available'
        ACTION_UNAVAILABLE = 'unavailable'

        def initialize(options = {})
          self.action = options.fetch(:action)
          self.entity = options.fetch(:entity)
          self.user = options.fetch(:user)
        end

        attr_accessor :entity, :action, :user
        private :entity=, :action=, :user=

        delegate :name, :action_type, to: :action
        alias_method :label, :name

        # This action, if it is rendered, is always available.
        def availability_state
          ACTION_AVAILABLE
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
