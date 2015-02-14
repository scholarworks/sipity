require_relative '../actions'
module Sipity
  module Decorators
    module Processing
      # An action that maps to the default Resourceful actions of a Rails model.
      # Its an overloaded word.
      class ResourcefulActionDecorator < BaseDecorator
        def path
          case name.to_s
          when 'show', 'destroy'
            view_context.work_path(entity)
          when 'edit', 'update'
            view_context.edit_work_path(entity)
          when 'new', 'create'
            view_context.new_work_path
          end
        end
      end
    end
  end
end
