require_relative '../actions'
module Sipity
  module Decorators
    module Actions
      # This action represents an action that is part of the Rails default
      # list of Resource based actions (i.e. show, new, edit, create, update,
      # destroy)
      class ResourcefulAction
        def initialize(options = {})
          self.name = options.fetch(:name)
          @entity = options.fetch(:entity)
          @view_context = options.fetch(:view_context) { default_view_context }
        end
        attr_reader :name, :entity

        # This action, if it is rendered, is always available.
        def availability_state
          'available'
        end

        def available?
          true
        end

        def path
          case name.to_s
          when 'show', 'destroy'
            view_context.work_path(entity)
          when 'edit', 'update'
            view_context.edit_work_path(entity)
          when 'new', 'create'
            view_context.new_work_path
          else
            # A catch in case the above magic strings and the above constant
            # get out of sink.
            fail Exceptions::UnprocessableResourcefulActionNameError, name
          end
        end

        private

        def name=(value)
          if RESOURCEFUL_ACTION_NAMES.include?(value)
            @name = value
          else
            fail Exceptions::UnprocessableResourcefulActionNameError, value
          end
        end

        attr_reader :view_context
        private :view_context

        def default_view_context
          Draper::ViewContext.current
        end
      end
    end
  end
end
