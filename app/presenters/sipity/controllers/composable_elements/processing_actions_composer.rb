require 'active_support/core_ext/array/wrap'

module Sipity
  module Controllers
    module ComposableElements
      # Responsible for encapsulating the processing actions and their
      # corresponding type for the given user and entity.
      class ProcessingActionsComposer
        # @note I am making an assumption that will later come back to haunt me;
        #   Namely that I want to skip certain processing actions. By default
        #   this is actions named 'show'; The present arrangement is that the
        #   "privileged" show action is the jumping off point for the other
        #   actions.
        def initialize(user:, entity:, repository: default_repository, action_names_to_skip: default_action_names_to_skip)
          self.entity = entity
          self.user = user
          self.repository = repository
          self.action_names_to_skip = action_names_to_skip
        end

        private

        attr_accessor :repository, :user, :entity
        attr_reader :action_names_to_skip

        def action_names_to_skip=(input)
          @action_names_to_skip = Array.wrap(input)
        end

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
          collection = begin
            if name.to_s == 'enrichment_actions'
              send("enrichment_actions_that_are_#{PowerConverter.convert_to_safe_for_method_name(identifier)}")
            else
              public_send(name)
            end
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
          ).reject { |processing_action| action_names_to_skip.include?(processing_action.name) }
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

        DEFAULT_ACTION_NAMES_TO_SKIP = ['show'].freeze
        def default_action_names_to_skip
          DEFAULT_ACTION_NAMES_TO_SKIP
        end
      end
    end
  end
end
