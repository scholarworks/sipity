module Sipity
  module Queries
    # Queries related to collaborators
    module CollaboratorQueries
      def find_or_initialize_collaborators_by(work:, id:, &block)
        Models::Collaborator.find_or_initialize_by(work_id: work.id, id: id, &block)
      end

      def collaborators_that_can_advance_the_current_state_of(work:, id: nil)
        work_collaborators_for(work: work, id: id, responsible_for_review: true)
      end

      def work_collaborators_for(options = {})
        Models::Collaborator.includes(:work).where(options.slice(:work, :role, :id, :responsible_for_review).compact)
      end

      def work_collaborator_names_for(options = {})
        work_collaborators_for(options).pluck(:name)
      end

      def work_collaborators_responsible_for_review(work:)
        work_collaborators_for(work: work, responsible_for_review: true)
      end
    end
  end
end
