module Sipity
  module Queries
    # Queries
    # Queries
    module AttachmentQueries
      def work_attachments(options = {})
        Models::Attachment.includes(:work).where(options.slice(:work))
      end
      module_function :work_attachments
      public :work_attachments
    end
  end
end
