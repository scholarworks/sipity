module Sip
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

    validates :title, presence: true
    validates :work_publication_strategy,
      presence: true,
      inclusion: { in: ->(obj) { obj.class.work_publication_strategies } }

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

    # TODO: This is exposed to allow the publication date to be set as part
    # of the Header creation. However it implies behavior that may or may
    # not exist in the views. So consider removing this attribute and crafting
    # a proper form object to reflect the input. After all, the validation
    # of :publication_date upon creation has something to do with the
    # :work_publication_strategy of 'already_published'
    attr_accessor :publication_date
  end
end
