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
      ATTACHED_FILES_COMPLETION_STATE_PREDICATE_NAME = 'attached_files_completion_state'.freeze
      AUTHOR_NAME = 'author_name'.freeze
      AWARD_CATEGORY = 'award_category'.freeze
      CATALOG_SYSTEM_NUMBER = 'catalog_system_number'.freeze
      CITATION_PREDICATE_NAME = 'citation'.freeze
      CITATION_STYLE_NAME = 'citation_style'.freeze
      CITATION_TYPE_PREDICATE_NAME = 'citationType'.freeze
      COLLABORATOR_PREDICATE_NAME = 'collaborator'.freeze
      COLLEGE_PREDICATE_NAME = 'college'.freeze
      COPYRIGHT_PREDICATE_NAME = 'copyright'.freeze
      COURSE_NAME_PREDICATE_NAME = 'course_name'.freeze
      COURSE_NUMBER_PREDICATE_NAME = 'course_number'.freeze
      DEFENSE_DATE_PREDICATE_NAME = 'defense_date'.freeze
      DEGREE_PREDICATE_NAME = 'degree'.freeze
      DOI_PREDICATE_NAME = 'identifier.doi'.freeze
      ETD_REVIEWER_SIGNOFF_DATE = 'ETD_REVIEWER_SIGNOFF_DATE'.freeze
      ETD_SUBMISSION_DATE = 'etd_submission_date'.freeze
      EXPECTED_GRADUATION_DATE = 'expected_graduation_date'.freeze
      LANGUAGE = 'language'.freeze
      LIBRARY_PROGRAM_NAME = 'library_program_name'.freeze
      MAJORS = 'majors'.freeze
      MINORS = 'minors'.freeze
      OCLC_NUMBER = 'oclc_number'.freeze
      ORGANIZATION_PREDICATE_NAME = 'organization'.freeze
      OTHER_RESOURCE_CONSULTED_PREDICATE_NAME = 'other_resource_consulted'.freeze
      PROGRAM_NAME_PREDICATE_NAME = 'program_name'.freeze
      PROJECT_ASSIGNED_TO_PERSON = 'project_assigned_to_person'.freeze
      PROJECT_DESCRIPTION = 'project_description'.freeze
      PROJECT_IMPACT = 'project_impact'.freeze
      PROJECT_ISSUE_TYPE = 'project_issue_type'.freeze
      PROJECT_JIRA_URL = 'project_jira_url'.freeze
      PROJECT_MANAGEMENT_SERVICES_REQUESTED = 'project_management_services_requested'.freeze
      PROJECT_MUST_COMPLETE_BY_DATE = 'project_must_complete_by_date'.freeze
      PROJECT_MUST_COMPLETE_BY_REASON = 'project_must_complete_by_reason'.freeze
      PROJECT_PRIORITY = 'project_priority'.freeze
      PROJECT_PROPOSAL_DECISION = 'project_proposal_decision'.freeze
      PUBLICATION_DATE_PREDICATE_NAME = 'publicationDate'.freeze
      PUBLICATION_NAME_PREDICATE_NAME = 'publication_name'.freeze
      PUBLISHER_PREDICATE_NAME = 'publisher'.freeze
      RESOURCE_CONSULTED_NAME = 'resource_consulted'.freeze
      SPATIAL_COVERAGE = 'spatial_coverage'.freeze
      SUBJECT = 'subject'.freeze
      SUBMISSION_ACCEPTED_FOR_PUBLICATION = 'submission_accepted_for_publication'.freeze
      SUBMITTED_FOR_PUBLICATION = 'submitted_for_publication'.freeze
      TEMPORAL_COVERAGE = 'temporal_coverage'.freeze
      USE_OF_LIBRARY_RESOURCES_PREDICATE_NAME = 'use_of_library_resources'.freeze
      WHOM_DOES_THIS_IMPACT = 'whom_does_this_impact'.freeze
      WORK_PATENT_STRATEGY = 'work_patent_strategy'.freeze
      WORK_PUBLICATION_STRATEGY = 'work_publication_strategy'.freeze

      self.table_name = 'sipity_additional_attributes'
      belongs_to :work, foreign_key: 'work_id'

      enum(
        key: {
          ABSTRACT_PREDICATE_NAME => ABSTRACT_PREDICATE_NAME,
          AFFILIATION_PREDICATE_NAME => AFFILIATION_PREDICATE_NAME,
          ALTERNATE_TITLE_PREDICATE_NAME => ALTERNATE_TITLE_PREDICATE_NAME,
          ATTACHED_FILES_COMPLETION_STATE_PREDICATE_NAME => ATTACHED_FILES_COMPLETION_STATE_PREDICATE_NAME,
          AUTHOR_NAME => AUTHOR_NAME,
          AWARD_CATEGORY => AWARD_CATEGORY,
          CATALOG_SYSTEM_NUMBER => CATALOG_SYSTEM_NUMBER,
          CITATION_PREDICATE_NAME => CITATION_PREDICATE_NAME,
          CITATION_STYLE_NAME => CITATION_STYLE_NAME,
          CITATION_TYPE_PREDICATE_NAME => CITATION_TYPE_PREDICATE_NAME,
          COLLABORATOR_PREDICATE_NAME => COLLABORATOR_PREDICATE_NAME,
          COLLEGE_PREDICATE_NAME => COLLEGE_PREDICATE_NAME,
          COPYRIGHT_PREDICATE_NAME => COPYRIGHT_PREDICATE_NAME,
          COURSE_NAME_PREDICATE_NAME => COURSE_NAME_PREDICATE_NAME,
          COURSE_NUMBER_PREDICATE_NAME => COURSE_NUMBER_PREDICATE_NAME,
          DEFENSE_DATE_PREDICATE_NAME => DEFENSE_DATE_PREDICATE_NAME,
          DEGREE_PREDICATE_NAME => DEGREE_PREDICATE_NAME,
          DOI_PREDICATE_NAME => DOI_PREDICATE_NAME,
          ETD_REVIEWER_SIGNOFF_DATE => ETD_REVIEWER_SIGNOFF_DATE,
          ETD_SUBMISSION_DATE => ETD_SUBMISSION_DATE,
          EXPECTED_GRADUATION_DATE => EXPECTED_GRADUATION_DATE,
          LANGUAGE => LANGUAGE,
          LIBRARY_PROGRAM_NAME => LIBRARY_PROGRAM_NAME,
          MAJORS => MAJORS,
          MINORS => MINORS,
          OCLC_NUMBER => OCLC_NUMBER,
          ORGANIZATION_PREDICATE_NAME => ORGANIZATION_PREDICATE_NAME,
          OTHER_RESOURCE_CONSULTED_PREDICATE_NAME => OTHER_RESOURCE_CONSULTED_PREDICATE_NAME,
          PROGRAM_NAME_PREDICATE_NAME => PROGRAM_NAME_PREDICATE_NAME,
          PROJECT_ASSIGNED_TO_PERSON => PROJECT_ASSIGNED_TO_PERSON,
          PROJECT_DESCRIPTION => PROJECT_DESCRIPTION,
          PROJECT_IMPACT => PROJECT_IMPACT,
          PROJECT_ISSUE_TYPE => PROJECT_ISSUE_TYPE,
          PROJECT_JIRA_URL => PROJECT_JIRA_URL,
          PROJECT_MANAGEMENT_SERVICES_REQUESTED => PROJECT_MANAGEMENT_SERVICES_REQUESTED,
          PROJECT_MUST_COMPLETE_BY_DATE => PROJECT_MUST_COMPLETE_BY_DATE,
          PROJECT_MUST_COMPLETE_BY_REASON => PROJECT_MUST_COMPLETE_BY_REASON,
          PROJECT_PRIORITY => PROJECT_PRIORITY,
          PROJECT_PROPOSAL_DECISION => PROJECT_PROPOSAL_DECISION,
          PUBLICATION_DATE_PREDICATE_NAME => PUBLICATION_DATE_PREDICATE_NAME,
          PUBLICATION_NAME_PREDICATE_NAME => PUBLICATION_NAME_PREDICATE_NAME,
          PUBLISHER_PREDICATE_NAME => PUBLISHER_PREDICATE_NAME,
          RESOURCE_CONSULTED_NAME => RESOURCE_CONSULTED_NAME,
          SPATIAL_COVERAGE => SPATIAL_COVERAGE,
          SUBJECT => SUBJECT,
          SUBMISSION_ACCEPTED_FOR_PUBLICATION => SUBMISSION_ACCEPTED_FOR_PUBLICATION,
          SUBMITTED_FOR_PUBLICATION => SUBMITTED_FOR_PUBLICATION,
          TEMPORAL_COVERAGE => TEMPORAL_COVERAGE,
          USE_OF_LIBRARY_RESOURCES_PREDICATE_NAME => USE_OF_LIBRARY_RESOURCES_PREDICATE_NAME,
          WHOM_DOES_THIS_IMPACT => WHOM_DOES_THIS_IMPACT,
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
