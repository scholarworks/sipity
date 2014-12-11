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
      def self.call(header_id:)
        new(header_id).as_hash
      end

      def initialize(header_id)
        # TODO: Should I be making use of the Repository?
        @header = Models::Header.find(header_id)
      end
      attr_reader :header
      private :header

      def as_hash
        {
          '_target' => permanent_url_for_header,
          'datacite.title' => title,
          'datacite.creator' => creator,
          'datacite.publisher' => publisher,
          'datacite.publicationyear' => publication_year
        }
      end

      private

      # The permanent URL in which we promise that you can always find this
      # object.
      #
      # TODO: Extract to a more prominent location; This is a permanent URL
      def permanent_url_for_header
        "http://change.me/show/#{header.id}"
      end

      def title
        header.title
      end

      def creator
        @creator ||= Repo::Support::Collaborators.for(header: header, roles: 'author').map(&:name).join("; ")
      end

      def publisher
        @publisher ||= begin
          Repo::Support::AdditionalAttributes.values_for(
            header: header, key: Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME
          ).join("; ")
        end
      end

      include Conversions::ConvertToYear

      def publication_year
        @publication_year ||=
          Repo::Support::AdditionalAttributes.values_for(header: header, key: Models::AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME).
          map { |publication_date| convert_to_year(publication_date).to_s }.join(", ")
      end
    end
  end
end
