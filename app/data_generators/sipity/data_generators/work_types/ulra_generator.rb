module Sipity
  module DataGenerators
    module WorkTypes
      # Responsible for generating the work types within the ETD.
      module UlraGenerator
        WORK_TYPE_NAMES = [
          Models::WorkType::ULRA_SUBMISSION
        ]
        PROCESSING_ROLE_NAMES = [
          Models::Role::CREATING_USER,
          Models::Role::ADVISOR,
          Models::Role::DATA_OBSERVER,
          Models::Role::ULRA_REVIEWER
        ]
        ULRA_REVIEW_COMMITTEE_GROUP_NAME = 'ULRA Review Committee'
      end
    end
  end
end
