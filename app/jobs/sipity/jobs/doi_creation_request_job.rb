module Sipity
  module Jobs
    class DoiCreationRequestJob
      def initialize(doi_creation_request_id)
        @doi_creation_request_id = doi_creation_request_id
      end
      attr_reader :doi_creation_request_id
      private :doi_creation_request_id

      def work
        # Find the DOI Creation Request
        # Guard REQUEST_NOT_YET_SUBMITTED? Maybe?
        # Update request to REQUEST_SUBMITTED
        # Submit remote request
        # Handle the response by assigning the DOI
        # Update DOI Creation Request state
      end
    end
  end
end
