module Sipity
  module Forms
    # The generalized work enrichment form. It is unlikely that you will be able
    # to use this directly.
    class WorkEnrichmentForm < ProcessingActionForm
      def initialize(attributes = {})
        super
        @enrichment_type = attributes.fetch(:enrichment_type) { default_enrichment_type }
      end
      attr_reader :enrichment_type

      private

      def default_enrichment_type
        self.class.to_s.sub(/^.*:(\w+)Form$/, '\1').underscore
      end
    end
  end
end
