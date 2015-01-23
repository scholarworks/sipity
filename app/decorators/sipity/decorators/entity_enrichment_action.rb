module Sipity
  module Decorators
    # Responsible for exposing the necessary information for rendering an
    # enrichment action (i.e. attach a file, describe the work)
    #
    # REVIEW: Should this object respond to render? Instead of requiring the
    #   template to render different elements.
    class EntityEnrichmentAction
      def initialize(entity:, name:, state: 'incomplete')
        @entity, @name, @state = entity, name, state
      end
      attr_reader :entity, :name, :state

      def path
        # REVIEW: Does EntityEnrichment even make sense?
        view_context.enrich_work_path(entity, name)
      end

      def label
        i18n_options = { scope: "sipity/decorators/entitiy_enrichment_actions.#{name}" }
        i18n_options[:entity_type] = entity.respond_to?(:work_type) ? entity.work_type : 'item'
        I18n.t(:label, i18n_options).html_safe
      end

      private

      def view_context
        Draper::ViewContext.current
      end
    end
  end
end
