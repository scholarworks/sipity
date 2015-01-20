module Sipity
  module Decorators
    # Responsible for exposing the necessary information for rendering an
    # enrichment action (i.e. attach a file, describe the work)
    #
    # REVIEW: Should this object respond to render? Instead of requiring the
    #   template to render different elements.
    class EntityEnrichmentAction
      def initialize(entity:, name:)
        @entity, @name = entity, name
      end
      attr_reader :entity, :name


      def status
        # REVIEW: This should not be static but is based on the state of the
        #   entity and the particular enrichment in question. It will be set
        #   elsewhere.
        'incomplete'
      end

      def path
        # REVIEW: Should I make use of a proper route method? Or is this even
        #   the correct routing method?
        File.join("#{view_context.polymorphic_path(entity)}", name)
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
