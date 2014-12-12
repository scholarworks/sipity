require 'sipity/models'
module Sipity
  module Models
    # The most basic of information required for generating a valid SIP
    class Header < ActiveRecord::Base
      self.table_name = 'sipity_headers'

      has_many :collaborators, foreign_key: :header_id, dependent: :destroy
      has_many :additional_attributes, foreign_key: :header_id, dependent: :destroy
      has_one :doi_creation_request, foreign_key: :header_id, dependent: :destroy

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

      def possible_work_publication_strategies
        self.class.work_publication_strategies
      end
    end
  end
end
