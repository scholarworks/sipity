module Sipity
  module Decorators
    # A decoration layer for Sipity::Work
    class WorkDecorator < ApplicationDecorator
      def self.object_class
        Models::Work
      end
      delegate_all
      decorates_association :collaborators, with: Decorators::CollaboratorDecorator
      decorates_association :attachments, with: Decorators::AttachmentDecorator

      def date_created
        object.created_at.strftime('%a, %d %b %Y')
      end

      def creators
        @creators ||= repository.scope_users_for_entity_and_roles(entity: object, roles: Models::Role::CREATING_USER)
      end

      def creator_names
        creators.map(&:name)
      end

      def title
        return if object.title.nil?
        object.title.html_safe
      end

      alias to_s  title

      def human_attribute_name(name)
        object.class.human_attribute_name(name)
      end

      def accessible_objects(predicate_name: :all)
        repository.access_rights_for_accessible_objects_of(work: object, predicate_name: predicate_name)
      end

      def comments(decorator: default_comment_decorator)
        @comments ||= repository.find_comments_for(entity: self).map do|comment|
          decorator.decorate(comment)
        end
      end

      def current_comments(decorator: default_comment_decorator)
        @current_comments ||= repository.find_current_comments_for(entity: self).map do|comment|
          decorator.decorate(comment)
        end
      end

      def selected_copyright(copyright_url, scrubber: Hesburgh::Lib::HtmlScrubber.build_inline_with_link_scrubber)
        copyright_value = repository.get_controlled_vocabulary_value_for(name: 'copyright', term_uri: copyright_url)
        scrubber.sanitize("<a href='#{copyright_url}'>#{copyright_value}</a>")
      end

      private

      def default_comment_decorator
        Decorators::Processing::ProcessingCommentDecorator
      end
    end
  end
end
