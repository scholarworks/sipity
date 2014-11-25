module Sip
  # A decoration layer for Sip::Header
  class HeaderDecorator < Draper::Decorator
    delegate_all
    decorates_association :collaborators

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

    def possible_work_publication_strategies
      object.class.work_publication_strategies
    end

    # When working on the form, I always want a blank element for the
    # collaborators.
    def collaborators_for_form
      object.collaborators.tap(&:build).map(&:decorate)
    end

    def authors
      object.collaborators.where(role: 'author').map(&:decorate)
    end

    private

    def recommendation_for(name)
      Recommendations.const_get("#{name.classify}Recommendation").new(header: self)
    end
  end
end
