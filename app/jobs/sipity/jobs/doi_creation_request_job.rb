module Sipity
  module Jobs
    # Responsible for processing a remote request for minting a DOI.
    class DoiCreationRequestJob
      def self.submit(doi_creation_request_id)
        new(doi_creation_request_id).work
      end

      # TODO: Refactor to use header_id; It is the more relevant identifier
      #   and will alleviate much of the underlying tests need to persist
      #   the relevant methods.
      def initialize(doi_creation_request_id, options = {})
        # Find the DOI Creation Request
        @doi_creation_request = Models::DoiCreationRequest.find(doi_creation_request_id)
        @metadata_gatherer = options.fetch(:metadata_gatherer) { default_metadata_gatherer }
        @minter = options.fetch(:minter) { default_minter }
        @minter_handled_exceptions = Array.wrap(options.fetch(:minter_handled_exceptions) { default_minter_handled_exceptions })
      end
      attr_reader :doi_creation_request, :minter, :minter_handled_exceptions, :metadata_gatherer
      delegate :header, to: :doi_creation_request

      def work
        # TODO: Do we need to track history for the given person?
        #   If so, who is the requester? Is it the DoiCreationRequest creating_user
        # TODO: Do we need to enforce via the authorization layer?

        # Guard REQUEST_NOT_YET_SUBMITTED? Maybe?
        guard_doi_creation_request_state!

        # Update request to REQUEST_SUBMITTED
        transition_doi_creation_request_to_submitted!
        # Submit remote request
        submit_remote_request! do |response|
          doi_creation_request.update(state: doi_creation_request.class::REQUEST_COMPLETED)
          Repo::Support::AdditionalAttributes.update!(
            header: header, key: Models::AdditionalAttribute::DOI_PREDICATE_NAME, values: response.id
          )
        end
      end

      private

      def guard_doi_creation_request_state!
        return true if doi_creation_request.request_failed?
        return true if doi_creation_request.request_not_yet_submitted?
        fail Exceptions::InvalidDoiCreationRequestStateError, entity: doi_creation_request, actual: doi_creation_request.state
      end

      def transition_doi_creation_request_to_submitted!
        doi_creation_request.update(state: doi_creation_request.class::REQUEST_SUBMITTED)
      end

      def submit_remote_request!
        yield(minter.call(metadata))
      rescue *minter_handled_exceptions => e
        # TODO: Should we catch and record this exception? If so where?
        doi_creation_request.update(state: doi_creation_request.class::REQUEST_FAILED, response_message: e.message)
        raise e
      end

      def metadata
        metadata_gatherer.call(header_id: doi_creation_request.header_id)
      end

      def default_minter
        ->(metadata) { Ezid::Identifier.create(metadata: metadata) }
      end

      def default_minter_handled_exceptions
        Ezid::Error
      end

      def default_metadata_gatherer
        Services::DoiCreationRequestMetadataGatherer
      end
    end
  end
end
