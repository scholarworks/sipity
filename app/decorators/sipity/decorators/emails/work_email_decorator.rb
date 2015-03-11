module Sipity
  module Decorators
    module Emails
      # Responsible for exposing methods required for email delivery. Nothing
      # too fancy.
      class WorkEmailDecorator
        def initialize(work)
          self.work = work
        end

        attr_reader :work
        private :work

        delegate :title, to: :work

        def work_type
          work.work_type.titleize
        end

        alias_method :document_type, :work_type
        deprecate :document_type

        # Related to building information for https://developers.google.com/gmail/markup/
        def email_message_action_url
          view_context.work_url(work)
        end

        def email_message_action_name
          "Review #{work_type}"
        end

        def email_message_action_description
          "Review #{work_type} “#{work.title}”"
        end

        def email_subject
          "#{view_context.t('application.name')}: #{email_message_action_description}"
        end

        private

        include Conversions::ConvertToWork
        def work=(object)
          @work = convert_to_work(object)
        end

        def view_context
          Draper::ViewContext.current
        end
      end
    end
  end
end
