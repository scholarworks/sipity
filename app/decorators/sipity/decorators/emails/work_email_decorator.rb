module Sipity
  module Decorators
    module Emails
      # Responsible for exposing methods required for email delivery. Nothing
      # too fancy.
      class WorkEmailDecorator
        def initialize(work, repository: default_repository)
          self.work = work
          self.repository = repository
        end

        include Conversions::SanitizeHtml
        def title
          work.to_s
        end

        def work_type
          Sipity::Controllers::TranslationAssistant.call(scope: :work_types, subject: work.work_type)
        end

        def collaborators
          @collaborators ||= repository.work_collaborators_for(work: work)
        end

        def reviewers
          @reviewers ||= repository.work_collaborators_responsible_for_review(work: work)
        end

        def creator_names
          creators.map(&:name)
        end

        def accessible_objects
          @accessible_objects ||= repository.access_rights_for_accessible_objects_of(work: work)
        end

        # TODO: The methods with `email_message_` prefix are ripe for extraction
        #   into a composed object. After all they are shared with the
        #   ProcessingCommentDecorator.
        # Related to building information for https://developers.google.com/gmail/markup/
        def email_message_action_url
          view_context.work_url(work)
        end

        def email_message_action_name
          "Review #{work_type}"
        end

        def email_message_action_description
          "Review #{work_type} “#{title}”"
        end

        private

        attr_reader :work
        attr_accessor :repository

        include Conversions::ConvertToWork
        def work=(object)
          @work = convert_to_work(object)
        end

        def view_context
          Draper::ViewContext.current
        end

        def default_repository
          QueryRepository.new
        end

        def creators
          @creators ||= repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::CREATING_USER)
        end
      end
    end
  end
end
