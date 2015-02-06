module Sipity
  module Queries
    # Queries
    module AttachmentQueries
      def work_attachments(options = {})
        Models::Attachment.includes(:work).where(options.slice(:work))
      end
    end
  end
end
