require 'sip/models'
module Sip
  module Models
    # The most basic of information required for generating a valid SIP
    class Header < ActiveRecord::Base
      self.table_name = 'sip_headers'

      has_many :collaborators, foreign_key: :sip_header_id, dependent: :destroy
      has_many :additional_attributes, foreign_key: :sip_header_id, dependent: :destroy
      has_one :doi_creation_request, foreign_key: :sip_header_id, dependent: :destroy

      accepts_nested_attributes_for(
        :collaborators,
        allow_destroy: true,
        reject_if: ->(collaborator_attributes) { collaborator_attributes['name'].blank? }
      )

      # While this make look ridiculous, if I use an Array, the enum declaration
      # insists on persisting the value as the index instead of the key. While
      # this might make more sense from a storage standpoint, it is not as clear
      # and leverages a more opaque assumption.
      enum(
        work_publication_strategy:
        {
          'will_not_publish' => 'will_not_publish',
          'already_published' => 'already_published',
          'going_to_publish' => 'going_to_publish',
          'do_not_know' => 'do_not_know'
        }
      )

      def possible_work_publication_strategies
        self.class.work_publication_strategies
      end
    end
  end
end
