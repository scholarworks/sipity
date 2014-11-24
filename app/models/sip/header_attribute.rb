module Sip
  # A rudimentary container for all - as of now string based - attributes
  # associated with the Sip::Header
  class HeaderAttribute < ActiveRecord::Base
    self.table_name = 'sip_collaborators'
    belongs_to :header, foreign_key: 'sip_header_id'
  end
end
