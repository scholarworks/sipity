module Sipity
  module Queries
    # Queries
    #
    # TODO: Remove module methods for these functions. I want them to be mixins
    #   instead of the existing singletons.
    module CollaboratorQueries
      def find_or_initialize_collaborators_by(work:, id:, &block)
        Models::Collaborator.find_or_initialize_by(work_id: work.id, id: id, &block)
      end

      def collaborators_that_can_advance_the_current_state_of(work:, id: nil)
        work_collaborators_for(work: work, id: id, responsible_for_review: true)
      end

      def work_collaborators_for(work:, pluck: nil, **keywords)
        work = Conversions::ConvertToWork.call(work)
        relation = Models::Collaborator.includes(:work).where(
          keywords.slice(:role, :id, :responsible_for_review, :identifier_id, :strategy, :identifying_value).compact
        ).where(work: work)
        return relation unless pluck.present?
        relation.pluck(*pluck)
      end

      def work_collaborator_names_for(**keywords)
        work_collaborators_for(pluck: :name, **keywords)
      end

      def work_collaborators_responsible_for_review(work:)
        work_collaborators_for(work: work, responsible_for_review: true)
      end
    end
  end
end
