require 'sipity/models'
module Sipity
  module Models
    # Responsible for tracking the state of a remote DOI request.
    class DoiCreationRequest < ActiveRecord::Base
      self.table_name = 'sipity_doi_creation_requests'
      belongs_to :header, foreign_key: 'header_id'

      REQUEST_NOT_YET_SUBMITTED = 'request_not_yet_submitted'.freeze
      REQUEST_SUBMITTED = 'request_submitted'.freeze
      REQUEST_COMPLETED = 'request_completed'.freeze
      REQUEST_FAILED = 'request_failed'.freeze

      enum(
        state:
        {
          REQUEST_NOT_YET_SUBMITTED => REQUEST_NOT_YET_SUBMITTED,
          REQUEST_SUBMITTED => REQUEST_SUBMITTED,
          REQUEST_COMPLETED => REQUEST_COMPLETED,
          REQUEST_FAILED => REQUEST_FAILED
        }
      )

      # Note: This is also enforced on the database
      after_initialize :set_initial_state, if: :new_record?

      private

      def set_initial_state
        self.state ||= REQUEST_NOT_YET_SUBMITTED
      end
    end
  end
end
