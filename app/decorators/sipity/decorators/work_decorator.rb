module Sipity
  module Decorators
    # A decoration layer for Sipity::Work
    class WorkDecorator < ApplicationDecorator
      include Conversions::SanitizeHtml
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
        @creators ||= repository.scope_creating_users_for_entity(entity: object)
      end

      def creator_names
        creators.map(&:name)
      end

      def title
        return if object.title.nil?
        object.title.html_safe
      end

      def to_s
        return if title.nil?
        remove_para_tag(title)
      end

      def human_attribute_name(name)
        object.class.human_attribute_name(name)
      end

      def accessible_objects
        @accessible_objects ||= repository.access_rights_for_accessible_objects_of(work: object)
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

      def selected_copyright(copyright_url)
        copyright_value = repository.get_controlled_vocabulary_value_for(name: 'copyright', term_uri: copyright_url)
        sanitize_html("<a href='#{copyright_url}'>#{copyright_value}</a>")
      end

      private

      def default_comment_decorator
        Decorators::Processing::ProcessingCommentDecorator
      end
    end
  end
end
