module Sipity
  module Jobs
    # Responsible for processing a remote request for minting a DOI.
    class DoiCreationRequestJob
      def initialize(doi_creation_request_id, options = {} )
        # Find the DOI Creation Request
        @doi_creation_request = Models::DoiCreationRequest.find(doi_creation_request_id)
        @minter = options.fetch(:minter) { default_minter }
        @minter_exceptions = Array.wrap(options.fetch(:minter_exceptions) { default_minter_exceptions })
      end
      attr_reader :doi_creation_request, :minter, :minter_exceptions
      private :doi_creation_request, :minter, :minter_exceptions

      def work
        # Guard REQUEST_NOT_YET_SUBMITTED? Maybe?
        guard_doi_creation_request_state!
        # Update request to REQUEST_SUBMITTED
        transition_doi_creation_request_to_submitted!
        # Submit remote request
        submit_remote_request!
      end

      private

      def guard_doi_creation_request_state!
        return true if doi_creation_request.request_failed?
        return true if doi_creation_request.request_not_yet_submitted?
        # TODO: Need a better exception
        fail RuntimeError
      end

      def transition_doi_creation_request_to_submitted!
        doi_creation_request.update(state: doi_creation_request.class::REQUEST_SUBMITTED)
      end

      def submit_remote_request!
        begin
          identifier = minter.call(metadata)
        rescue *minter_exceptions => e
          doi_creation_request.update(state: doi_creation_request.class::REQUEST_FAILED)
        end
      end

      def metadata
        {
          '_target' => '',
          'datacite.creator' => '',
          'datacite.title' => '',
          'datacite.publisher' => '',
          'datacite.publicationyear' => ''
        }
      end

      def default_minter
        ->(metadata) { Ezid::Identifier.create(metadata: metadata) }
      end

      def default_minter_exceptions
        Ezid::Error
      end
    end
  end
end
