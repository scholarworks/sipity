module Sipity
  module Services
    # Responsible for gathering the parameters for the DOI Minting request
    class DoiCreationRequestMetadataGatherer
      def self.call(header_id:)
        new(header_id).as_hash
      end

      def initialize(header_id)
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

      # The permanent URL in which we promise that you can always find this
      # object.
      def permanent_url_for_header
        "http://change.me/show/#{header.id}"
      end

      def title
        header.title
      end

      def creator
        Repo::Support::Collaborators.for(header: header, roles: 'author').
          map { |author| author.name }.join("; ")
      end

      def publisher
        Repo::Support::AdditionalAttributes.
          values_for(header: header, key: Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME).
          join("; ")
      end

      def publication_year
        publication_dates = Repo::Support::AdditionalAttributes.
          values_for(header: header, key: Models::AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME)
        publication_dates.map { |publication_date| extract_year_from(publication_date).to_s }.join(", ")
      end

      def extract_year_from(date)
        2014
      end
    end
  end
end
