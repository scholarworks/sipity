module Sipity
  module Jobs
    # Responsible for processing a remote request for minting a DOI.
    class DoiCreationRequestJob
      def self.submit(work_id)
        new(work_id).call
      end

      def initialize(work_id, options = {})
        @repository = options.fetch(:repository) { default_repository }
        @minter = options.fetch(:minter) { default_minter }
        @minter_handled_exceptions = options.fetch(:minter_handled_exceptions) { default_minter_handled_exceptions }
        @work = repository.find_work(work_id)
        @doi_creation_request = repository.find_doi_creation_request(work: work)
      end
      attr_reader :work, :doi_creation_request, :minter, :minter_handled_exceptions, :metadata_gatherer, :repository

      def call
        # TODO: Do we need to track history for the given person?
        #   If so, who is the requester? Is it the DoiCreationRequest creating_user
        # TODO: Do we need to enforce via the authorization layer?
        guard_doi_creation_request_state!
        submit_remote_request! do |response|
          handle_remote_response!(response)
        end
      end

      private

      def guard_doi_creation_request_state!
        return true if doi_creation_request.request_failed?
        return true if doi_creation_request.request_not_yet_submitted?
        fail Exceptions::InvalidDoiCreationRequestStateError, entity: doi_creation_request, actual: doi_creation_request.state
      end

      def transition_doi_creation_request_to_submitted!
        repository.update_work_doi_creation_request_state!(work: work, state: :request_submitted)
      end

      def submit_remote_request!
        transition_doi_creation_request_to_submitted!
        yield(minter.call(metadata))
      rescue *Array.wrap(minter_handled_exceptions) => e
        repository.update_work_doi_creation_request_state!(work: work, state: :request_failed, response_message: e.message)
        raise e
      end

      def handle_remote_response!(response)
        repository.update_work_attribute_values!(
          work: work, key: Models::AdditionalAttribute::DOI_PREDICATE_NAME, values: response.id
        )
        repository.update_work_doi_creation_request_state!(work: work, state: :request_completed)
      end

      def metadata
        repository.gather_doi_creation_request_metadata(work: work)
      end

      def default_minter
        ->(metadata) { Ezid::Identifier.create(metadata: metadata) }
      end

      def default_minter_handled_exceptions
        Ezid::Error
      end

      def default_repository
        # REVIEW: Do I want multiple repositories to exist?
        CommandRepository.new
      end
    end
  end
end
