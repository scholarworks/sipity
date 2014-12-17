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
      def self.call(header:)
        new(header).as_hash
      end

      def initialize(header)
        @header = header
      end
      attr_reader :header
      private :header

      def as_hash
        {
          '_target' => permanent_uri_for_header,
          'datacite.title' => title,
          'datacite.creator' => creator,
          'datacite.publisher' => publisher,
          'datacite.publicationyear' => publication_year
        }
      end

      private

      # The permanent URL in which we promise that you can always find this
      # object.
      def permanent_uri_for_header
        Conversions::ConvertToPermanentUri.call(header)
      end

      def title
        header.title
      end

      def creator
        @creator ||= RepositoryMethods::Support::Collaborators.names_for(header: header, roles: 'author').join("; ")
      end

      def publisher
        @publisher ||= begin
          RepositoryMethods::Support::AdditionalAttributes.values_for(
            header: header, key: Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME
          ).join("; ")
        end
      end

      def publication_year
        @publication_year ||=
          RepositoryMethods::Support::AdditionalAttributes.
          values_for(header: header, key: Models::AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME).
          map { |publication_date| Conversions::ConvertToYear.call(publication_date).to_s }.join(", ")
      end
    end
  end
end
