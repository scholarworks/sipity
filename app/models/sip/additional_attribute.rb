module Sip
  # A rudimentary container for all (as of now string based) attributes
  # associated with the Sip::Header
  class AdditionalAttribute < ActiveRecord::Base
    DOI_PREDICATE_NAME = 'identifier.doi'.freeze
    CITATION_PREDICATE_NAME = 'citation'.freeze
    CITATION_TYPE_PREDICATE_NAME = 'citationType'.freeze
    PUBLISHER_PREDICATE_NAME = 'publisher'.freeze
    PUBLICATION_DATE_PREDICATE_NAME = 'publicationDate'.freeze

    self.table_name = 'sip_additional_attributes'
    belongs_to :header, foreign_key: 'sip_header_id'
  end
end
