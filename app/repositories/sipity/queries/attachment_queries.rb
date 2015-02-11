module Sipity
  module Queries
    # Queries
    module AttachmentQueries
      def work_attachments(options = {})
        Models::Attachment.includes(:work).where(options.slice(:work))
      end

      def find_or_initialize_attachments_by(work:, pid:)
        Models::Attachment.find_or_initialize_by(work_id: work.id, pid: pid)
      end

      def representative_attachment_for(work:)
        Models::Attachment.where(work_id: work.id, is_representative_file: true)
      end

      module_function :representative_attachment_for
      public :representative_attachment_for
    end
  end
end
