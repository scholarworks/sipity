require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        # Exposes a means of assigning copyright
        class CopyrightForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:copyright]
          )
          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.copyright = attributes.fetch(:copyright) { copyright_from_work }
          end

          include ActiveModel::Validations
          validates :copyright, presence: true, inclusion: { in: :available_copyrights_for_validation }

          def available_copyrights
            repository.get_controlled_vocabulary_entries_for_predicate_name(name: 'copyright')
          end

          def available_copyrights_for_validation
            available_copyrights.map(&:term_uri)
          end

          def submit
            processing_action_form.submit(requested_by: requested_by) do
              repository.update_work_attribute_values!(work: work, key: 'copyright', values: copyright)
            end
          end

          private

          def copyright_from_work
            repository.work_attribute_values_for(work: work, key: 'copyright', cardinality: 1)
          end
        end
      end
    end
  end
end
