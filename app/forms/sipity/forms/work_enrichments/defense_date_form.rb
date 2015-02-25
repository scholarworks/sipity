module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means defining the thesis defense date todo item.
      class DefenseDateForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          self.defense_date = parse_input_defense_date(attributes)
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
          return nil unless work
          # REVIEW: I really need to derive this information from the repository.
          # It is something that should be injected on form build.
          Queries::AdditionalAttributeQueries.work_attribute_values_for(work: work, key: 'defense_date').first
        end

        def parse_input_defense_date(attributes = {})
          # Because Rails date input builder generates 3 inpute fields for a date (year, month, day).
          # This is here to capture that specific implementation. Note, it will be something that will
          # require a general conversion.
          if attributes.key?(:defense_date)
            attributes.fetch(:defense_date)
          elsif attributes.key?("defense_date(1i)") && attributes.key?("defense_date(2i)") && attributes.key?("defense_date(3i)")
            "#{attributes['defense_date(1i)'].to_i}-#{attributes['defense_date(2i)'].to_i}-#{attributes['defense_date(3i)'].to_i}"
          else
            defense_date_from_work
          end
        end

        def defense_date=(value)
          @defense_date = convert_to_date(value)
        end

        def convert_to_date(value)
          case value
          when Date, DateTime then value
          when NilClass then value
          else
            Date.parse(value)
          end
        rescue TypeError, ArgumentError
          nil
        end
      end
    end
  end
end
