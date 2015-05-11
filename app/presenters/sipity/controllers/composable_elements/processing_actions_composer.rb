module Sipity
  module Controllers
    module ComposableElements
      # Responsible for encapsulating the processing actions and their
      # corresponding type for the given user and entity.
      class ProcessingActionsComposer
        def initialize(user:, entity:, repository: default_repository)
          self.entity = entity
          self.user = user
          self.repository = repository
        end

        private

        attr_accessor :repository, :user, :entity

        public

        def resourceful_actions
          @resourceful_actions ||= processing_actions.select(&:resourceful_action?)
        end

        def resourceful_actions?
          resourceful_actions.present?
        end

        def state_advancing_actions
          @state_advancing_actions ||= processing_actions.select(&:state_advancing_action?)
        end

        def state_advancing_actions?
          state_advancing_actions.present?
        end

        def enrichment_actions
          @enrichment_actions ||= processing_actions.select(&:enrichment_action?)
        end

        def enrichment_actions?
          enrichment_actions.present?
        end

        def enrichment_action_set_for(identifier:)
          collection = send("enrichment_actions_that_are_#{PowerConverter.convert_to_safe_for_method_name(identifier)}")
          Parameters::ActionSet.new(identifier: identifier, collection: collection)
        end

        private

        def enrichment_actions_that_are_optional
          enrichment_actions.select { |action| !action_ids_that_are_prerequisites.include?(action.id) }
        end

        def enrichment_actions_that_are_required
          enrichment_actions.select { |action| action_ids_that_are_prerequisites.include?(action.id) }
        end

        def processing_actions
          @processing_actions ||= repository.scope_permitted_entity_strategy_actions_for_current_state(user: user, entity: entity)
        end

        def action_ids_that_are_prerequisites
          @action_ids_that_are_prerequisites ||= repository.scope_strategy_actions_that_are_prerequisites(entity: entity, pluck: :id)
        end

        def default_repository
          QueryRepository.new
        end
      end
    end
  end
end
