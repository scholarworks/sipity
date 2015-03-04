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

      def work_collaborators_for(options = {})
        Models::Collaborator.includes(:work).where(options.slice(:work, :role, :id, :responsible_for_review).compact)
      end

      def work_collaborator_names_for(options = {})
        work_collaborators_for(options).pluck(:name)
      end

      def work_collaborators_responsible_for_review(work:)
        work_collaborators_for(work: work, responsible_for_review: true)
      end

      # @api public
      #
      # @see #work_collaborating_users_responsible_for_review
      #
      # @return Array of usernames
      def usernames_of_those_that_are_collaborating_and_responsible_for_review(work:)
        work_collaborating_users_responsible_for_review(work: work).pluck(:username)
      end

      def work_collaborating_users_responsible_for_review(work:)
        collaborators_scope = work_collaborators_responsible_for_review(work: work)
        User.where(
          User.arel_table[:username].in(
            collaborators_scope.arel_table.project(
              collaborators_scope.arel_table[:netid]
            ).where(
              collaborators_scope.constraints.reduce.and(collaborators_scope.arel_table[:netid].not_eq(nil))
            )
          )
        )
      end
    end
  end
end
