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
          work.work_type
        end

        delegate :comment, :actor, :entity, to: :@processing_comment
        delegate :title, to: :work
        private :actor, :entity

        # Related to building information for https://developers.google.com/gmail/markup/
        def email_message_action_url
          view_context.work_url(work)
        end

        def email_message_action_name
          "Review comments"
        end

        def email_message_action_description
          "Review comments for “#{title}”"
        end

        def email_subject
          "#{view_context.t('application.name')}: #{email_message_action_description}"
        end

        private

        def work
          entity.proxy_for
        end

        def view_context
          Draper::ViewContext.current
        end
      end
    end
  end
end
