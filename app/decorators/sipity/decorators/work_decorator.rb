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

      def with_form_panel(name, theme = :default, &block)
        # TODO: Translate name following active record internationalization
        # conventions.
        h.render(layout: 'sipity/form_panel', locals: { name: name, theme: theme, object: self }, &block)
      end

      def date_created
        object.created_at.strftime('%a, %d %b %Y')
      end

      def creators
        @creators ||= repository.scope_users_for_entity_and_roles(entity: object, roles: Models::Role::CREATING_USER)
      end

      def creator_names
        creators.map(&:name)
      end

      def to_s
        title.html_safe
      end

      def human_attribute_name(name)
        object.class.human_attribute_name(name)
      end

      def accessible_objects
        @accessible_objects ||= repository.access_rights_for_accessible_objects_of(work: object)
      end

      include Conversions::SanitizeHtml
      def sanitize_html(attribute)
        Conversions::SanitizeHtml.call(attribute).html_safe
      end

      def authors(decorator: Decorators::CollaboratorDecorator)
        repository.work_collaborators_for(work: object, role: 'author').map { |obj| decorator.decorate(obj) }
      end

      def state_advancing_actions(user:)
        processing_actions(user: user).state_advancing_actions
      end

      def resourceful_actions(user:)
        processing_actions(user: user).resourceful_actions
      end

      def enrichment_actions(user:)
        processing_actions(user: user).enrichment_actions.each_with_object({}) do |action, mem|
          mem['required'] ||= []
          mem['optional'] ||= []
          if action.is_a_prerequisite?
            mem['required'] << action
          else
            mem['optional'] << action
          end
          mem
        end
      end

      def comments(decorator: default_comment_decorator)
        @comments ||= repository.find_comments_for_work(work: self).map do|comment|
          decorator.decorate(comment)
        end
      end

      def current_comments(decorator: default_comment_decorator)
        @current_comments ||= repository.find_current_comments_for_work(work: self).map do|comment|
          decorator.decorate(comment)
        end
      end

      def selected_copyright(copyright_url)
        copyright_value = repository.get_controlled_vocabulary_value_for(name: 'copyright', term_uri: copyright_url)
        "<a href='#{copyright_url}'>#{copyright_value}</a>"
      end

      private

      def default_comment_decorator
        Decorators::Processing::ProcessingCommentDecorator
      end

      def processing_actions(user:)
        @processing_actions ||= ProcessingActions.new(user: user, entity: self)
      end
    end
  end
end
