module Sipity
  # :nodoc:
  module Commands
    # Commands
    module WorkCommands
      # Responsible for assigning collaborators to a work.
      def assign_collaborators_to(work:, collaborators:)
        Array.wrap(collaborators).each do |collaborator|
          collaborator.work_id = work.id
          collaborators.save!
        end
      end

      def update_processing_state!(entity:, to:)
        # REVIEW: Should this be re-finding the work? Is it cheating to re-use
        #   the given work? Is it unsafe as far as state is concerned?
        entity.update(processing_state: to)
      end

      # TODO: Create a PidMinter service
      # REVIEW: Is this the correct location to put this behavior?
      def attach_file_to(work:, file:, user: user, pid_minter: -> {})
        pid = pid_minter.call
        Models::Attachment.create!(work: work, file: file, pid: pid, predicate_name: 'attachment')
      end
    end
  end
end
