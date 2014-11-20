module Sip
  # The most basic of information required for generating a valid SIP
  class Header < ActiveRecord::Base
    self.table_name = 'sip_headers'
  end
end
