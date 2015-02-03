module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means for attaching files to the associated work.
      class CollaboratorForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          self.collaborators_attributes = attributes[:collaborators_attributes]
        end
        attr_reader :collaborators_attributes

        # When the form is being rendered, the attributes drive on this object
        # Thus
        def collaborators
          @collaborators || collaborators_from_work
        end

        validate :each_collaborator_must_be_valid

        # Mirroring the expected behavior/implementation of the
        # :accepts_nested_attributes_for Rails method and its sibling :fields_for
        #
        # TODO: make sure we don't keep making new items
        def collaborators_attributes=(inputs)
          return inputs unless inputs.present?
          @collaborators = []
          inputs.each do |_, attributes|
            build_collaborator_from_input(@collaborators, attributes)
          end
          @collaborators_attributes = inputs
        end

        private

        def save(repository:, requested_by:)
          super { repository.assign_collaborators_to(work: work, collaborators: collaborators) }
        end

        def collaborators_from_work
          return [] unless work
          work.collaborators.present? ? work.collaborators : [Models::Collaborator.build_default]
        end

        def each_collaborator_must_be_valid
          return true if collaborators.all?(&:valid?)
          errors.add(:collaborators_attributes, 'are incomplete')
        end

        def build_collaborator_from_input(collection, attributes)
          return if !attributes[:name].present? && !attributes[:id].present?
          collaborator = work.collaborators.find_or_initialize_by(id: attributes[:id])
          collaborator.attributes = extract_collaborator_attributes(attributes)
          collection << collaborator
        end

        def extract_collaborator_attributes(attributes)
          permitted_attributes = attributes.slice(:name, :role, :netid, :email, :responsible_for_review)
          # Because Rails strong parameters may or may not be in play.
          permitted_attributes.permit! if permitted_attributes.respond_to?(:permit!)
          permitted_attributes
        end
      end
    end
  end
end
