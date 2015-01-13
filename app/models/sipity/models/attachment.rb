module Sipity
  module Models
    # Represents a single file attached to a given work.
    class Attachment < ActiveRecord::Base
      self.table_name = 'sipity_attachments'
      belongs_to :work
    end
  end
end
