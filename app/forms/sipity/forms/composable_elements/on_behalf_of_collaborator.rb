module Sipity
  module Forms
    module ComposableElements
      # A composable form element to include a few queries related to on behalf
      # of behavior.
      class OnBehalfOfCollaborator
        def initialize(form:, repository:)
          self.form = form
          self.repository = repository
        end

        private

        attr_accessor :repository
        attr_reader :form

        public

        attr_accessor :on_behalf_of_collaborator_id

        def valid_on_behalf_of_collaborators
          # TODO: This can be consolidated into a singular query
          repository.collaborators_that_can_advance_the_current_state_of(work: form.entity) -
            repository.collaborators_that_have_taken_the_action_on_the_entity(entity: form.entity, actions: form.to_processing_action)
        end

        def on_behalf_of_collaborator
          repository.collaborators_that_can_advance_the_current_state_of(work: form.entity, id: on_behalf_of_collaborator_id).first
        end

        def valid_on_behalf_of_collaborator_ids
          valid_on_behalf_of_collaborators.map { |collaborator| collaborator.id.to_s }
        end

        include GuardInterfaceExpectation
        def form=(input)
          guard_interface_expectation!(input, :entity, :to_processing_action)
          @form = input
        end
      end
    end
  end
end
