module Sipity
  module Decorators
    module Processing
      # An action that maps to the default Resourceful actions of a Rails model.
      # Its an overloaded word.
      class ResourcefulActionDecorator < BaseDecorator
        DESTROY_ACTION_NAME = 'destroy'.freeze
        VALID_ACTION_NAMES = %w(show destroy edit update new create).freeze

        def path
          case name.to_s
          when 'show', DESTROY_ACTION_NAME
            view_context.work_path(entity)
          when 'edit', 'update'
            view_context.edit_work_path(entity)
          when 'new', 'create'
            view_context.new_work_path
          end
        end

        def button_class
          dangerous? ? 'btn-danger' : 'btn-primary'
        end

        private

        def dangerous?
          name.to_s == DESTROY_ACTION_NAME
        end

        def action=(action)
          if action.respond_to?(:name) && VALID_ACTION_NAMES.include?(action.name)
            super(action)
          else
            fail Exceptions::UnprocessableResourcefulActionNameError, container: action
          end
        end
      end
    end
  end
end
