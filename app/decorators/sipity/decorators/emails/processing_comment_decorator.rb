module Sipity
  module Decorators
    module Emails
      # Responsible for exposing methods required for email delivery. Nothing
      # too fancy.
      class ProcessingCommentDecorator
        def initialize(processing_comment)
          self.processing_comment = processing_comment
        end

        attr_accessor :processing_comment
        private :processing_comment=, :processing_comment

        def name_of_commentor
          actor.proxy_for.name
        end

        def work_type
          work.work_type.titleize
        end

        include Conversions::SanitizeHtml
        def title
          sanitize_html(work.title)
        end

        delegate :comment, :actor, :entity, to: :processing_comment
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
