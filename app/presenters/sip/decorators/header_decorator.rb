module Sipity
  module Decorators
    # A decoration layer for Sipity::Header
    class HeaderDecorator < Draper::Decorator
      def self.object_class
        Models::Header
      end
      delegate_all
      decorates_association :collaborators, with: Decorators::CollaboratorDecorator

      def fieldset_for(name)
        # TODO: Translate name following active record internationalization
        # conventions.
        h.field_set_tag(name, class: h.dom_class(object, name)) do
          yield
        end
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
        Repo::Support::Collaborators.for(header: object, role: 'author').map { |obj| decorator.decorate(obj) }
      end

      private

      def recommendation_for(name)
        Recommendations.const_get("#{name.classify}Recommendation").new(header: self)
      end
    end
  end
end
