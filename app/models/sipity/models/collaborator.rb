require 'sipity/models'
module Sipity
  module Models
    # A collaborator (as per metadata not improving on the SIP) for the underlying
    # work's SIP.
    class Collaborator < ActiveRecord::Base
      AUTHOR_ROLE = DEFAULT_ROLE = 'author'.freeze
      ADVISOR_ROLE = 'advisor'.freeze
      CONTRIBUTOR_ROLE = 'contributor'.freeze

      def self.build_default
        new(role: DEFAULT_ROLE)
      end

      belongs_to :sip, foreign_key: 'sip_id'

      self.table_name = 'sipity_collaborators'

      # REVIEW: Do I want validations here? I'm relying on the CreateSipForm
      #   to check for collaborators and use the underlying ActiveRecord
      #   validations. However, the role requirement is enforced via the
      #   database.
      validates :role, presence: true

      # While this make look ridiculous, if I use an Array, the enum declaration
      # insists on persisting the value as the index instead of the key. While
      # this might make more sense from a storage standpoint, it is not as clear
      # and leverages a more opaque assumption.
      enum(
        role:
        {
          ADVISOR_ROLE => ADVISOR_ROLE,
          AUTHOR_ROLE => AUTHOR_ROLE,
          CONTRIBUTOR_ROLE => CONTRIBUTOR_ROLE
        }
      )

      def possible_roles
        self.class.roles
      end
    end
  end
end
