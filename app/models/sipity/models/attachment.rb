module Sipity
  module Models
    # Represents a single file attached to a given work.
    class Attachment < ActiveRecord::Base
      extend Dragonfly::Model
      self.table_name = 'sipity_attachments'
      self.primary_key = :pid

      validates :is_representative_file, uniqueness: { scope: :work_id }, if: :is_representative_file?

      alias_attribute :name, :file_name

      belongs_to :work
      dragonfly_accessor :file
    end
  end
end
