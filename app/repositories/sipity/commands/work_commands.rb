module Sipity
  # :nodoc:
  module Commands
    # Commands
    module WorkCommands
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::WorkQueries)
      end

      def update_processing_state!(work:, to:)
        # REVIEW: Should this be re-finding the work? Is it cheating to re-use
        #   the given work? Is it unsafe as far as state is concerned?
        work.update(processing_state: to)
      end

      # TODO: Create a PidMinter service
      # REVIEW: Is this the correct location to put this behavior?
      def attach_file_to(work:, file:, user: user, pid_minter: -> {})
        pid = pid_minter.call
        Models::Attachment.create!(work: work, file: file, pid: pid, predicate_name: 'attachment')
      end
    end
    private_constant :WorkCommands
  end
end
