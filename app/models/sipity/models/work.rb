require 'sipity/models'
module Sipity
  module Models
    # The most basic of information required for generating a valid work.
    class Work < ActiveRecord::Base
      self.table_name = 'sipity_works'

      # @!attribute [rw] :processing_state The processing state of the work.
      #   @return [String]
      alias_attribute :processing_status, :processing_state

      has_many :collaborators, foreign_key: :work_id, dependent: :destroy
      has_many :additional_attributes, foreign_key: :work_id, dependent: :destroy
      has_many :attachments, foreign_key: :work_id, dependent: :destroy
      has_one :doi_creation_request, foreign_key: :work_id, dependent: :destroy

      # TODO: Extract to TransientAnswer
      ALREADY_PUBLISHED = 'already_published'.freeze
      WILL_NOT_PUBLISH = 'will_not_publish'.freeze
      GOING_TO_PUBLISH = 'going_to_publish'.freeze
      DO_NOT_KNOW = 'do_not_know'.freeze

      ETD_WORK_TYPE = 'ETD'.freeze

      # While this make look ridiculous, if I use an Array, the enum declaration
      # insists on persisting the value as the index instead of the key. While
      # this might make more sense from a storage standpoint, it is not as clear
      # and leverages a more opaque assumption.
      enum(
        work_publication_strategy:
        {
          WILL_NOT_PUBLISH => WILL_NOT_PUBLISH,
          ALREADY_PUBLISHED => ALREADY_PUBLISHED,
          GOING_TO_PUBLISH => GOING_TO_PUBLISH,
          DO_NOT_KNOW => DO_NOT_KNOW
        },
        work_type:
        {
          ETD_WORK_TYPE => ETD_WORK_TYPE
        }
      )

      after_initialize :set_default_work_type, if:  :new_record?

      private

      def set_default_work_type
        # HACK: Given that we are first working on the ETD submission, this
        # is an acceptable hack. However, as we move forward, it may not be.
        self.work_type ||= ETD_WORK_TYPE
      end
    end
  end
end