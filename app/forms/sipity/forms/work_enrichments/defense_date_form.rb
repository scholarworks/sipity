module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means defining the thesis defense date todo item.
      class DefenseDateForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          @defense_date = attributes.fetch(:defense_date) { defense_date_from_work }
        end

        attr_accessor :defense_date
        validates :defense_date, presence: true

        private

        def save(repository:, requested_by:)
          super do
            repository.update_work_attribute_values!(work: work, key: 'defense_date', values: defense_date)
          end
        end

        def defense_date_from_work
          return [] unless work
          # REVIEW: I really need to derive this information from the repository.
          # It is something that should be injected on form build.
          Queries::AdditionalAttributeQueries.work_attribute_values_for(work: work, key: 'defense_date').first
        end
      end
    end
  end
end
