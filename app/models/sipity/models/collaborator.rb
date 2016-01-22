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
      RESEARCH_DIRECTOR_ROLE = DEFAULT_ROLE = 'Research Director'.freeze
      COMMITTEE_MEMBER_ROLE =  'Committee Member'.freeze
      ADVISING_FACULTY_ROLE = 'Advising Faculty'.freeze

      def self.build_default
        new
      end

      belongs_to :work, foreign_key: 'work_id'
      belongs_to :user, primary_key: 'username', foreign_key: 'netid'
      has_one :processing_actor, dependent: :destroy, as: :proxy_for, class_name: 'Sipity::Models::Processing::Actor'

      include Conversions::ConvertToProcessingActor
      def to_processing_actor
        if user.present?
          convert_to_processing_actor(user)
        else
          processing_actor || create_processing_actor!
        end
      end

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
      validates :email, format: { without: /@nd\.edu\Z/, message: :disallow_nd_dot_edu_emails }

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
          RESEARCH_DIRECTOR_ROLE => RESEARCH_DIRECTOR_ROLE,
          COMMITTEE_MEMBER_ROLE => COMMITTEE_MEMBER_ROLE,
          ADVISING_FACULTY_ROLE => ADVISING_FACULTY_ROLE
        }
      )

      def to_s
        name
      end

      before_save :nilify_blank_values

      private

      def nilify_blank_values
        # TODO: I really dislike callbacks; Lets not use them in the future.
        # However, for now, they are needed until I can do a data migration.
        self.netid = nil unless netid.present?
        self.email = nil unless email.present?
      end
    end
  end
end
