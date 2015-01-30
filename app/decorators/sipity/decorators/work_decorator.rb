module Sipity
  module Decorators
    # A decoration layer for Sipity::Work
    class WorkDecorator < ApplicationDecorator
      def self.object_class
        Models::Work
      end
      delegate_all
      decorates_association :collaborators, with: Decorators::CollaboratorDecorator

      def with_form_panel(name, theme = :default, &block)
        # TODO: Translate name following active record internationalization
        # conventions.
        h.render(layout: 'sipity/form_panel', locals: { name: name, theme: theme, object: self }, &block)
      end

      def with_action_pane(name, &block)
        h.render(layout: 'sipity/form_action_pane', locals: { name: name, object: self }, &block)
      end

      def to_s
        title
      end

      def with_recommendation(recommendation_name)
        yield(recommendation_for(recommendation_name))
      end

      def human_attribute_name(name)
        object.class.human_attribute_name(name)
      end

      def authors(decorator: Decorators::CollaboratorDecorator)
        repository.work_collaborators_for(work: object, role: 'author').map { |obj| decorator.decorate(obj) }
      end

      def available_linked_actions(user:, action_name:, action_set_builder: Services::ActionSet.method(:new))
        return [] unless user.present?
        event_names = repository.available_event_triggers_for(user: user, entity: self)
        action_set_builder.call(repository: repository, event_names: event_names, entity: self, current_action: action_name)
      end

      def each_todo_item_set
        # TODO: There is a violation of demeter, in part because I don't have the concept
        # of a todo_list set.
        repository.todo_list_for_current_processing_state_of_work(work: self).sets.each do |name, items|
          yield(name, items) if items.present?
        end
      end

      private

      def recommendation_for(name)
        Recommendations.const_get("#{name.classify}Recommendation").new(work: self)
      end
    end
  end
end
