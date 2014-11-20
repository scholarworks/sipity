module Sip
  # The most basic of information required for generating a valid SIP
  class Header < ActiveRecord::Base
    self.table_name = 'sip_headers'
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
