require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Responsible for capturing and validating information for publisher information
        class PublisherInformationForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:publication_name]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.publication_name = attributes.fetch(:publication_name) { publication_name_from_work }
          end

          include ActiveModel::Validations
          include Hydra::Validations
          validates :publication_name, presence: true

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: 'publication_name', values: publication_name)
            end
          end

          private

          def publication_name_from_work
            repository.work_attribute_values_for(work: work, key: 'publication_name', cardinality: 1)
          end
        end
      end
    end
  end
end
