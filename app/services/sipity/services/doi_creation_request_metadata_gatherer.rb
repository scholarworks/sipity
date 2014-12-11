module Sipity
  module Services
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
        ''
      end

      def publisher
        ''
      end

      def publication_year
        ''
      end
    end
  end
end
