module Sipity
  module Decorators
    module Emails
      # Responsible for exposing methods required for email delivery. Nothing
      # too fancy.
      class WorkEmailDecorator
        def initialize(work, repository: default_repository)
          self.work = work
          @repository = repository
        end

        attr_reader :work, :repository
        private :work, :repository

        delegate :title, to: :work

        def work_type
          work.work_type.titleize
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

        alias_method :document_type, :work_type
        deprecate :document_type

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

        def email_message_action_name
          "Review #{work_type}"
        end

        def email_message_action_description
          "Review #{work_type} “#{title}”"
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
