module Sipity
  module Models
    # A rudimentary container for all (as of now string based) attributes
    # associated with the Sipity::Work
    class AdditionalAttribute < ActiveRecord::Base
      # TODO: Create a map for input name to key and vice versa
      DOI_PREDICATE_NAME = 'identifier.doi'.freeze
      CITATION_PREDICATE_NAME = 'citation'.freeze
      CITATION_TYPE_PREDICATE_NAME = 'citationType'.freeze
      PUBLISHER_PREDICATE_NAME = 'publisher'.freeze
      PUBLICATION_DATE_PREDICATE_NAME = 'publicationDate'.freeze
      ABSTRACT_PREDICATE_NAME = 'abstract'.freeze
      DEFENSE_DATE_PREDICATE_NAME = 'defense_date'.freeze
      DEGREE_PREDICATE_NAME = 'degree'.freeze
      PROGRAM_NAME_PREDICATE_NAME = 'program_name'.freeze
      ALTERNATE_TITLE_PREDICATE_NAME = 'alternate_title'.freeze
      COPYRIGHT_PREDICATE_NAME = 'copyright'.freeze
      SUBJECT = 'subject'.freeze
      LANGUAGE = 'language'.freeze
      TEMPORAL_COVERAGE = 'temporal_coverage'.freeze
      SPATIAL_COVERAGE = 'spatial_coverage'.freeze
      RESOURCE_CONSULTED_NAME = 'resource_consulted'.freeze
      CITATION_STYLE_NAME = 'citation_style'.freeze
      AWARD_CATEGORY = 'award_category'.freeze
      EXPECTED_GRADUATION_DATE = 'expected_graduation_date'.freeze
      MAJORS = 'majors'.freeze

      self.table_name = 'sipity_additional_attributes'
      belongs_to :work, foreign_key: 'work_id'

      enum(
        key: {
          DOI_PREDICATE_NAME => DOI_PREDICATE_NAME,
          CITATION_PREDICATE_NAME => CITATION_PREDICATE_NAME,
          CITATION_TYPE_PREDICATE_NAME => CITATION_TYPE_PREDICATE_NAME,
          PUBLISHER_PREDICATE_NAME => PUBLISHER_PREDICATE_NAME,
          PUBLICATION_DATE_PREDICATE_NAME => PUBLICATION_DATE_PREDICATE_NAME,
          ABSTRACT_PREDICATE_NAME => ABSTRACT_PREDICATE_NAME,
          DEFENSE_DATE_PREDICATE_NAME => DEFENSE_DATE_PREDICATE_NAME,
          DEGREE_PREDICATE_NAME => DEGREE_PREDICATE_NAME,
          PROGRAM_NAME_PREDICATE_NAME => PROGRAM_NAME_PREDICATE_NAME,
          ALTERNATE_TITLE_PREDICATE_NAME => ALTERNATE_TITLE_PREDICATE_NAME,
          COPYRIGHT_PREDICATE_NAME => COPYRIGHT_PREDICATE_NAME,
          SUBJECT => SUBJECT,
          LANGUAGE => LANGUAGE,
          TEMPORAL_COVERAGE => TEMPORAL_COVERAGE,
          SPATIAL_COVERAGE => SPATIAL_COVERAGE,
          RESOURCE_CONSULTED_NAME => RESOURCE_CONSULTED_NAME,
          CITATION_STYLE_NAME => CITATION_STYLE_NAME,
          AWARD_CATEGORY => AWARD_CATEGORY,
          EXPECTED_GRADUATION_DATE => EXPECTED_GRADUATION_DATE,
          MAJORS => MAJORS
        }
      )
    end
  end
end
