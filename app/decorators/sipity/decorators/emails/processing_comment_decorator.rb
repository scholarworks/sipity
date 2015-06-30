module Sipity
  module Decorators
    module Emails
      # Responsible for exposing methods required for email delivery. Nothing
      # too fancy.
      class ProcessingCommentDecorator
        def initialize(processing_comment)
          self.processing_comment = processing_comment
        end

        def work_type
          Sipity::Controllers::TranslationAssistant.call(scope: :work_types, subject: work.work_type)
        end

        include Conversions::SanitizeHtml
        def title
          work.to_s
        end

        delegate :comment, :entity, :name_of_commentor, to: :processing_comment
        private :entity

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

        attr_reader :processing_comment

        def processing_comment=(input)
          @processing_comment = PowerConverter.convert(input, to: :processing_comment)
        end

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
