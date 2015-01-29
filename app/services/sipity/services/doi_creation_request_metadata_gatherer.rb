module Sipity
  module Services
    # Responsible for gathering the parameters for the DOI Minting request.
    #
    # @note: I debated about where this information should reside. It made sense
    #   to be part of the DoiCreationRequestJob, however this information is
    #   relevant for more than the asynchronous job; It could be used as
    #   validation, or display as we send that information on to remote
    #   services. Ultimately, I found it easier to test this singular concern
    #   as something separate from the job.
    class DoiCreationRequestMetadataGatherer
      # A convenience method to codify the external API.
      def self.call(work:)
        new(work).as_hash
      end

      def initialize(work, options = {})
        @work = work
        # TODO: I don't want to craft a custom repository
        @repository = options.fetch(:repository) { default_repository }
      end
      attr_reader :work, :repository
      private :work, :repository

      def as_hash
        {
          '_target' => permanent_uri_for_work,
          'datacite.title' => title,
          'datacite.creator' => creator,
          'datacite.publisher' => publisher,
          'datacite.publicationyear' => publication_year
        }
      end

      private

      # The permanent URL in which we promise that you can always find this
      # object.
      def permanent_uri_for_work
        Conversions::ConvertToPermanentUri.call(work)
      end

      def title
        work.title
      end

      def creator
        @creator ||= repository.work_collaborator_names_for(work: work, roles: 'author').join("; ")
      end

      def publisher
        @publisher ||= begin
          repository.work_attribute_values_for(
            work: work, key: Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME
          ).join("; ")
        end
      end

      def publication_year
        @publication_year ||= begin
          repository.work_attribute_values_for(
            work: work, key: Models::AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME
          ).map { |publication_date| convert_to_year(publication_date).to_s }.join(", ")
        end
      end
      include Conversions::ConvertToYear

      def default_repository
        QueryRepository.new
      end
    end
  end
end
