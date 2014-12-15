module Sipity
  module Models
    # Responsible for persisting requests for an Account Placeholder
    class AccountPlaceholder < ActiveRecord::Base
      self.table_name = 'sipity_account_placeholders'

      CREATED_STATE = 'created'.freeze
      CLAIMED_STATE = 'claimed'.freeze

      NETID_IDENTIFIER_TYPE = 'netid'.freeze
      ORCID_IDENTIFIER_TYPE = 'orcid'.freeze

      enum(
        state:
        {
          CREATED_STATE => CREATED_STATE,
          CLAIMED_STATE => CLAIMED_STATE
        },
        identifier_type:
        {
          ORCID_IDENTIFIER_TYPE => ORCID_IDENTIFIER_TYPE,
          NETID_IDENTIFIER_TYPE => NETID_IDENTIFIER_TYPE
        }
      )

      # Note: This is also enforced on the database
      after_initialize :set_initial_state, if: :new_record?

      private

      def set_initial_state
        self.state ||= CREATED_STATE
      end
    end
  end
end
