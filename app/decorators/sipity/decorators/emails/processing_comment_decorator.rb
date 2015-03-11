module Sipity
  module Decorators
    module Emails
      # Responsible for exposing methods required for email delivery. Nothing
      # too fancy.
      class ProcessingCommentDecorator
        def initialize(processing_comment)
          @processing_comment = processing_comment
        end

        def name_of_commentor
          actor.proxy_for.name
        end

        def document_type
          entity.proxy_for.work_type
        end

        delegate :comment, :actor, :entity, to: :@processing_comment
      end
    end
  end
end
