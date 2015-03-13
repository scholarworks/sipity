module Sipity
  module Decorators
    module Emails
      # Responsible for exposing methods required for email delivery. Nothing
      # too fancy.
      class RegisteredActionDecorator
        def initialize(registered_action, repository: default_repository)
          self.registered_action = registered_action
          @repository = repository
        end

        attr_reader :repository, :registered_action
        private :repository

        delegate :entity, to: :registered_action

        # TODO: The methods with `email_message_` prefix are ripe for extraction
        #   into a composed object. After all they are shared with the
        #   ProcessingCommentDecorator.
        # Related to building information for https://developers.google.com/gmail/markup/
        def email_message_action_url
          view_context.work_url(work)
        end
        alias_method :review_link, :email_message_action_url
        alias_method :work_show_path, :email_message_action_url
        deprecate :review_link
        deprecate :work_show_path

        def action_taken_at
          registered_action.created_at
        end

        def requested_by
          registered_action.requested_by_actor.proxy_for
        end

        def on_behalf_of
          registered_action.on_behalf_of_actor.proxy_for
        end

        def email_message_action_name
          "Go to #{work_type}"
        end

        def email_message_action_description
          "Go to #{work_type} “#{title}”"
        end

        def email_subject
          "#{view_context.t('application.name')}: #{email_message_action_description}"
        end

        def work_type
          work.work_type.titleize
        end

        delegate :title, to: :work

        private

        def work
          entity.proxy_for
        end

        include Conversions::ConvertToRegisteredAction
        def registered_action=(object)
          @registered_action = convert_to_registered_action(object)
        end

        def view_context
          Draper::ViewContext.current
        end

        def default_repository
          QueryRepository.new
        end
      end
    end
  end
end