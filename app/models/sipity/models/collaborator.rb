require 'sipity/models'
module Sipity
  module Models
    # A collaborator (as per metadata not improving on the SIP) for the underlying
    # work's SIP.
    class Collaborator < ActiveRecord::Base
      AUTHOR_ROLE = DEFAULT_ROLE = 'author'.freeze
      ADVISOR_ROLE = 'advisor'
      CONTRIBUTOR_ROLE = 'contributor'

      def self.build_default
        new(role: DEFAULT_ROLE)
      end

      belongs_to :header, foreign_key: 'header_id'

      self.table_name = 'sipity_collaborators'

      validates :role, inclusion: { in: ->(obj) { obj.possible_roles } }

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
