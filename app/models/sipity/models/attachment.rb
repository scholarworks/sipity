module Sipity
  module Models
    # Represents a single file attached to a given work.
    class Attachment < ActiveRecord::Base
      extend Dragonfly::Model
      self.table_name = 'sipity_attachments'
      self.primary_key = :pid

      validates :is_representative_file, uniqueness: { scope: :work_id }, if: :is_representative_file?

      alias_attribute :name, :file_name

      has_many :access_rights, as: :entity, dependent: :destroy

      def to_s
        file_name
      end

      belongs_to :work
      dragonfly_accessor :file

      THUMBNAIL_HEIGHT = THUMBNAIL_WIDTH = '64'.freeze
      def thumbnail_url(width: THUMBNAIL_WIDTH, height: THUMBNAIL_HEIGHT)
        if file.image?
          file.thumb("#{width}x#{height}#").url
        else
          extname = File.extname(file.name).sub(/^\./, '') + '.png'
          File.join(Dragonfly.app.server.url_host, 'extname_thumbnails', width, height, extname)
        end
      end

      delegate :url, to: :file, prefix: :file, allow_nil: true
      delegate :path, to: :file, prefix: :file, allow_nil: true
    end
  end
end
