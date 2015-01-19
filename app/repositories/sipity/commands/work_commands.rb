module Sipity
  # :nodoc:
  module Commands
    # Commands
    module WorkCommands
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::WorkQueries)
      end
      def update_processing_state!(work:, new_processing_state:)
        # REVIEW: Should this be re-finding the work? Is it cheating to re-use
        #   the given work? Is it unsafe as far as state is concerned?
        work.update(processing_state: new_processing_state)
      end
    end
    private_constant :WorkCommands
  end
end
