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

        def can_advance_processing_state?
          (state_advancing_actions & actions_with_incomplete_prerequisites).empty?
        end

        def action_set_for(name:, identifier: nil)
          if name.to_s == 'enrichment_actions'
            collection = send("enrichment_actions_that_are_#{PowerConverter.convert_to_safe_for_method_name(identifier)}")
          else
            collection = public_send(name)
          end
          Parameters::ActionSetParameter.new(identifier: identifier, collection: collection, entity: entity)
        end

        private

        def enrichment_actions_that_are_optional
          enrichment_actions.select { |action| !action_ids_that_are_prerequisites.include?(action.id) }
        end

        def enrichment_actions_that_are_required
          enrichment_actions.select { |action| action_ids_that_are_prerequisites.include?(action.id) }
        end

        def processing_actions
          @processing_actions ||= Array.wrap(
            repository.scope_permitted_entity_strategy_actions_for_current_state(user: user, entity: entity)
          )
        end

        def action_ids_that_are_prerequisites
          @action_ids_that_are_prerequisites ||= Array.wrap(
            repository.scope_strategy_actions_that_are_prerequisites(entity: entity, pluck: :id)
          )
        end

        def actions_with_incomplete_prerequisites
          @actions_with_incomplete_prerequisites ||= Array.wrap(
            repository.scope_strategy_actions_with_incomplete_prerequisites(entity: entity)
          )
        end

        def default_repository
          QueryRepository.new
        end
      end
    end
  end
end
