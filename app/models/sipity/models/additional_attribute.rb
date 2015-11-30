require 'hesburgh/lib/html_scrubber'

module Sipity
  module Models
    # A rudimentary container for all (as of now string based) attributes
    # associated with the Sipity::Work
    class AdditionalAttribute < ActiveRecord::Base
      # The format in which we will persist "well-formed" dates into
      # the additional attribute table.
      DATE_FORMAT = '%Y-%m-%d'.freeze

      # TODO: Create a map for input name to key and vice versa
      ABSTRACT_PREDICATE_NAME = 'abstract'.freeze
      AFFILIATION_PREDICATE_NAME = 'affiliation'.freeze
      ALTERNATE_TITLE_PREDICATE_NAME = 'alternate_title'.freeze
      AUTHOR_NAME = 'author_name'.freeze
      AWARD_CATEGORY = 'award_category'.freeze
      CATALOG_SYSTEM_NUMBER = 'catalog_system_number'.freeze
      CITATION_PREDICATE_NAME = 'citation'.freeze
      CITATION_STYLE_NAME = 'citation_style'.freeze
      CITATION_TYPE_PREDICATE_NAME = 'citationType'.freeze
      COLLABORATOR_PREDICATE_NAME = 'collaborator'.freeze
      COPYRIGHT_PREDICATE_NAME = 'copyright'.freeze
      DEFENSE_DATE_PREDICATE_NAME = 'defense_date'.freeze
      DEGREE_PREDICATE_NAME = 'degree'.freeze
      DOI_PREDICATE_NAME = 'identifier.doi'.freeze
      ETD_REVIEWER_SIGNOFF_DATE = 'ETD_REVIEWER_SIGNOFF_DATE'.freeze
      ETD_SUBMISSION_DATE = 'etd_submission_date'.freeze
      EXPECTED_GRADUATION_DATE = 'expected_graduation_date'.freeze
      LANGUAGE = 'language'.freeze
      MAJORS = 'majors'.freeze
      OCLC_NUMBER = 'oclc_number'.freeze
      ORGANIZATION_PREDICATE_NAME = 'organization'.freeze
      PROGRAM_NAME_PREDICATE_NAME = 'program_name'.freeze
      PUBLICATION_DATE_PREDICATE_NAME = 'publicationDate'.freeze
      PUBLISHER_PREDICATE_NAME = 'publisher'.freeze
      RESOURCE_CONSULTED_NAME = 'resource_consulted'.freeze
      SPATIAL_COVERAGE = 'spatial_coverage'.freeze
      SUBJECT = 'subject'.freeze
      TEMPORAL_COVERAGE = 'temporal_coverage'.freeze
      WORK_PATENT_STRATEGY = 'work_patent_strategy'.freeze
      WORK_PUBLICATION_STRATEGY = 'work_publication_strategy'.freeze

      self.table_name = 'sipity_additional_attributes'
      belongs_to :work, foreign_key: 'work_id'

      enum(
        key: {
          ABSTRACT_PREDICATE_NAME => ABSTRACT_PREDICATE_NAME,
          AFFILIATION_PREDICATE_NAME => AFFILIATION_PREDICATE_NAME,
          ALTERNATE_TITLE_PREDICATE_NAME => ALTERNATE_TITLE_PREDICATE_NAME,
          AUTHOR_NAME => AUTHOR_NAME,
          AWARD_CATEGORY => AWARD_CATEGORY,
          CATALOG_SYSTEM_NUMBER => CATALOG_SYSTEM_NUMBER,
          CITATION_PREDICATE_NAME => CITATION_PREDICATE_NAME,
          CITATION_STYLE_NAME => CITATION_STYLE_NAME,
          CITATION_TYPE_PREDICATE_NAME => CITATION_TYPE_PREDICATE_NAME,
          COLLABORATOR_PREDICATE_NAME => COLLABORATOR_PREDICATE_NAME,
          COPYRIGHT_PREDICATE_NAME => COPYRIGHT_PREDICATE_NAME,
          DEFENSE_DATE_PREDICATE_NAME => DEFENSE_DATE_PREDICATE_NAME,
          DEGREE_PREDICATE_NAME => DEGREE_PREDICATE_NAME,
          DOI_PREDICATE_NAME => DOI_PREDICATE_NAME,
          ETD_REVIEWER_SIGNOFF_DATE => ETD_REVIEWER_SIGNOFF_DATE,
          ETD_SUBMISSION_DATE => ETD_SUBMISSION_DATE,
          EXPECTED_GRADUATION_DATE => EXPECTED_GRADUATION_DATE,
          LANGUAGE => LANGUAGE,
          MAJORS => MAJORS,
          OCLC_NUMBER => OCLC_NUMBER,
          ORGANIZATION_PREDICATE_NAME => ORGANIZATION_PREDICATE_NAME,
          PROGRAM_NAME_PREDICATE_NAME => PROGRAM_NAME_PREDICATE_NAME,
          PUBLICATION_DATE_PREDICATE_NAME => PUBLICATION_DATE_PREDICATE_NAME,
          PUBLISHER_PREDICATE_NAME => PUBLISHER_PREDICATE_NAME,
          RESOURCE_CONSULTED_NAME => RESOURCE_CONSULTED_NAME,
          SPATIAL_COVERAGE => SPATIAL_COVERAGE,
          SUBJECT => SUBJECT,
          TEMPORAL_COVERAGE => TEMPORAL_COVERAGE,
          WORK_PATENT_STRATEGY => WORK_PATENT_STRATEGY,
          WORK_PUBLICATION_STRATEGY => WORK_PUBLICATION_STRATEGY
        }
      )

      # The predicate definitions are nearby, so that is why I'm providing the
      # lookup container.
      def self.scrubber_for(predicate_name:, container: Hesburgh::Lib::HtmlScrubber)
        return container.build_inline_scrubber if predicate_name.to_s =~ /title\Z/
        container.build_block_scrubber
      end
    end
  end
end
