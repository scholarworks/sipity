require 'sipity/models'
module Sipity
  module Models
    # A collaborator for the given work. These are the named people that
    # collaborated on the creation of the scholarly work (i.e. they helped write
    # the paper). It is not the people that collaborated on the processing of
    # the work (i.e. they signed off on the metadata for accurancy or
    # completeness).
    #
    # @see Sipity::Models::Processing::Actor
    # @see Sipity::Models::Role
    class Collaborator < ActiveRecord::Base
      AUTHOR_ROLE = DEFAULT_ROLE = 'author'.freeze
      ADVISOR_ROLE = 'advisor'.freeze
      CONTRIBUTOR_ROLE = 'contributor'.freeze

      def self.build_default
        new(role: DEFAULT_ROLE)
      end

      belongs_to :work, foreign_key: 'work_id'

      self.table_name = 'sipity_collaborators'

      # REVIEW: Do I want validations here? I'm relying on the CreateWorkForm
      #   to check for collaborators and use the underlying ActiveRecord
      #   validations. However, the role requirement is enforced via the
      #   database.
      validates :role, presence: true

      # REVIEW: I don't like the validations on the model, but this is a concession
      #   for DLTP-360. Ideally another form builder tool would work.
      #   I would prefer forms to represent business logic/validations.
      validates :name, presence: true
      validate :validate_required_information_if_responsible_for_review
      validates :netid, net_id: true

      def validate_required_information_if_responsible_for_review
        return true unless responsible_for_review?
        return true if netid.present? || email.present?
        errors.add(:netid)
        errors.add(:email)
        errors.add(:responsible_for_review)
      end
      private :validate_required_information_if_responsible_for_review

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
