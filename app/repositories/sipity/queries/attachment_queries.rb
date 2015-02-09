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

      def work_representative(work:)
        Models::Attachment.where(work_id: work.id, is_representative_file: true).pluck(:pid)
      end

      module_function :work_representative
      public :work_representative
    end
  end
end
