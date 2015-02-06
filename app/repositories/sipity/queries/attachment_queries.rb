module Sipity
  module Queries
    # Queries
    module AttachmentQueries
      def work_attachments(options = {})
        Models::Attachment.includes(:work).where(options.slice(:work))
      end

      def find_or_initialize_attachments_by(work:, pid:)
        Models::Attachment.find_or_initialize_by(work_id: work.id, pid: pid, &block)
      end
    end
  end
end
