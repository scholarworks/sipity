module Sipity
  module Decorators
    module Actions
      # This action is one that can change the process
      class ProcessingStateChangingAction
        def initialize(options = {})
          @name = options.fetch(:name)
          @entity = options.fetch(:entity)
          @repository = options.fetch(:repository) { default_repository }
          @view_context = options.fetch(:view_context) { default_view_context }
        end
        attr_reader :name, :entity

        def availability_state
          @availability_state ||= query_for_availability_state
        end

        def available?
          availability_state == 'available'
        end

        def path
          view_context.event_trigger_for_work_path(entity, name)
        end

        private

        attr_reader :repository
        private :repository

        def default_repository
          QueryRepository.new
        end

        def query_for_availability_state
          if repository.are_all_of_the_required_todo_items_done_for_work?(work: entity)
            'available'
          else
            'unavailable'
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
