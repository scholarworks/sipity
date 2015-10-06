require 'active_support/core_ext/array/wrap'

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
          @collaborators ||= Array.wrap(repository.work_collaborators_for(work: work))
        end

        def reviewers
          @reviewers ||= Array.wrap(repository.work_collaborators_responsible_for_review(work: work))
        end

        def additional_committe_members
          collaborators - reviewers
        end

        def creator_names
          creators.map(&:name)
        end

        def creator_netids
          creators.map(&:username)
        end

        def accessible_objects
          @accessible_objects ||= Array.wrap(repository.access_rights_for_accessible_objects_of(work: work))
        end

        def work_access
          @work_access ||= Models::AccessRightFacade.new(work, work: work)
        end

        def accessible_files
          @accessible_files ||= Array.wrap(repository.work_attachments(work: work)).map do |object|
            Models::AccessRightFacade.new(object, work: work)
          end
        end

        # TODO: The methods with `email_message_` prefix are ripe for extraction
        #   into a composed object. After all they are shared with the
        #   ProcessingCommentDecorator.
        # Related to building information for https://developers.google.com/gmail/markup/
        def email_message_action_url
          view_context.work_url(work)
        end

        def program_names
          Array.wrap(repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::PROGRAM_NAME_PREDICATE_NAME))
        end

        def degree
          Array.wrap(repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::DEGREE_PREDICATE_NAME))
        end

        def publishing_intent
          Array.wrap(repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::WORK_PUBLICATION_STRATEGY))
        end

        def patent_intent
          Array.wrap(repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::WORK_PATENT_STRATEGY))
        end

        def submission_date
          Array.wrap(repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::ETD_SUBMISSION_DATE))
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
          @creators ||= Array.wrap(repository.scope_creating_users_for_entity(entity: work))
        end
      end
    end
  end
end
