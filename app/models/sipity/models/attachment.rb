module Sipity
  module Models
    # Represents a single file attached to a given sip.
    class Attachment < ActiveRecord::Base
      self.table_name = 'sipity_attachments'
      belongs_to :sip
    end
  end
end
