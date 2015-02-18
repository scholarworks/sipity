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

      def with_action_pane(name, css_class = '', &block)
        h.render(layout: 'sipity/form_action_pane', locals: { name: name, css_class: css_class, object: self }, &block)
      end

      def to_s
        title
      end

      def human_attribute_name(name)
        object.class.human_attribute_name(name)
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

      private

      def processing_actions(user:)
        @processing_actions ||= ProcessingActions.new(user: user, entity: self)
      end
    end
  end
end
