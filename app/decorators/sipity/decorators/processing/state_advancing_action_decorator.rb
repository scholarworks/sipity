module Sipity
  module Decorators
    module Processing
      # An action that will advance the state of a given entity.
      class StateAdvancingActionDecorator < BaseDecorator
        def initialize(options = {})
          super
          @repository = options.fetch(:repository) { default_repository }
        end

        def availability_state
          @availability_state ||= query_for_availability_state
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
          if repository.scope_strategy_actions_with_incomplete_prerequisites(entity: entity).include?(action)
            STATE_PREREQUISITES_NOT_MET
          else
            STATE_AVAILABLE
          end
        end
      end
    end
  end
end
