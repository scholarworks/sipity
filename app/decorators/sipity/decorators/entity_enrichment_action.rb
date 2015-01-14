module Sipity
  module Decorators
    # Responsible for exposing the necessary information for rendering an
    # enrichment action (i.e. attach a file, describe the work)
    #
    # REVIEW: Should this object respond to render? Instead of requiring the
    #   template to render different elements.
    class EntityEnrichmentAction
      extend ActiveModel::Translation
      def initialize(entity:, name:)
        @entity, @name = entity, name
      end
      attr_reader :entity, :name

      def path
        File.join("#{view_context.polymorphic_path(entity)}", name)
      end

      private

      def view_context
        Draper::ViewContext.current
      end
    end
  end
end
