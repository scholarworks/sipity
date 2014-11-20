module Sip
  # The most basic of information required for generating a valid SIP
  class Header < ActiveRecord::Base
    self.table_name = 'sip_headers'

    has_many :collaborators, foreign_key: :sip_header_id
    accepts_nested_attributes_for :collaborators, allow_destroy: true

    validates :title, presence: true
    enum(
      work_publication_strategy:
      {
        will_not_publish: :will_not_publish,
        already_published: :already_published,
        going_to_publish: :going_to_publish,
        do_not_know: :do_not_know
      }
    )
  end
end
