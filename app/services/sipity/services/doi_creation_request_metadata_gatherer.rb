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
      def self.call(sip:)
        new(sip).as_hash
      end

      def initialize(sip, options = {})
        @sip = sip
        # TODO: I don't want to craft a custom repository
        @repository = options.fetch(:repository) { default_repository }
      end
      attr_reader :sip, :repository
      private :sip, :repository

      def as_hash
        {
          '_target' => permanent_uri_for_sip,
          'datacite.title' => title,
          'datacite.creator' => creator,
          'datacite.publisher' => publisher,
          'datacite.publicationyear' => publication_year
        }
      end

      private

      # The permanent URL in which we promise that you can always find this
      # object.
      def permanent_uri_for_sip
        Conversions::ConvertToPermanentUri.call(sip)
      end

      def title
        sip.title
      end

      def creator
        @creator ||= repository.sip_collaborator_names_for(sip: sip, roles: 'author').join("; ")
      end

      def publisher
        @publisher ||= begin
          repository.sip_attribute_values_for(
            sip: sip, key: Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME
          ).join("; ")
        end
      end

      def publication_year
        @publication_year ||= begin
          repository.sip_attribute_values_for(
            sip: sip, key: Models::AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME
          ).map { |publication_date| Conversions::ConvertToYear.call(publication_date).to_s }.join(", ")
        end
      end

      def default_repository
        Repository.new
      end
    end
  end
end
