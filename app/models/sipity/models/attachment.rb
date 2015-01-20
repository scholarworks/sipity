module Sipity
  module Models
    # Represents a single file attached to a given work.
    class Attachment < ActiveRecord::Base
      extend Dragonfly::Model
      self.table_name = 'sipity_attachments'
      self.primary_key = :pid

      belongs_to :work
      dragonfly_accessor :file
    end
  end
end
