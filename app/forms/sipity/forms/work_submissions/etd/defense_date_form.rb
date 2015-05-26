module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Exposes a means defining the thesis defense date todo item.
        class DefenseDateForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work, attribute_names: [:defense_date]
          )

          include Conversions::ExtractInputDateFromInput
          def initialize(work:, attributes: {}, **keywords)
            self.work = work
            self.processing_action_form = ProcessingForm.new(form: self, **keywords)
            self.defense_date = extract_input_date_from_input(:defense_date, attributes) { defense_date_from_work }
          end

          include ActiveModel::Validations
          validates :defense_date, presence: true

          private

          def save(requested_by:)
            repository.update_work_attribute_values!(work: work, key: 'defense_date', values: defense_date)
          end

          def defense_date_from_work
            return nil unless work
            Array.wrap(repository.work_attribute_values_for(work: work, key: 'defense_date')).first
          end

          include Conversions::ConvertToDate
          def defense_date=(value)
            @defense_date = convert_to_date(value) { nil }
          end
        end
      end
    end
  end
end
