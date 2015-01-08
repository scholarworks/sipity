require 'sipity/models'
module Sipity
  module Models
    # The most basic of information required for generating a valid SIP.
    class Sip < ActiveRecord::Base
      self.table_name = 'sipity_sips'

      # @!attribute [rw] :processing_state The processing state of the sip.
      #   @return [String]
      alias_attribute :processing_status, :processing_state

      has_many :collaborators, foreign_key: :sip_id, dependent: :destroy
      has_many :additional_attributes, foreign_key: :sip_id, dependent: :destroy
      has_one :doi_creation_request, foreign_key: :sip_id, dependent: :destroy

      # REVIEW: Do I really want to deal with nested attributes such as these?
      #   It smells suspicious.
      accepts_nested_attributes_for(
        :collaborators,
        allow_destroy: true,
        reject_if: ->(collaborator_attributes) { collaborator_attributes['name'].blank? }
      )

      ALREADY_PUBLISHED = 'already_published'.freeze
      WILL_NOT_PUBLISH = 'will_not_publish'.freeze
      GOING_TO_PUBLISH = 'going_to_publish'.freeze
      DO_NOT_KNOW = 'do_not_know'.freeze

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
        }
      )

      attr_reader :work_type

      def possible_work_publication_strategies
        self.class.work_publication_strategies
      end

      def work_type=(work_type)
        fail ArgumentError unless Sip.work_types.key?(work_type)
        @work_type = Sip.work_types.fetch(work_type)
      end

      def self.work_types
        { 'ETD' => 'ETD' }
      end
    end
  end
end
