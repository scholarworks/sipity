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
            attribute_names: [:publication_name, :allow_pre_prints]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.publication_name = attributes.fetch(:publication_name) { publication_name_from_work }
            self.allow_pre_prints = attributes.fetch(:allow_pre_prints) { allow_pre_prints_from_work }
          end

          include ActiveModel::Validations
          include Hydra::Validations
          validates :publication_name, presence: true

          VALID_VALUES_FOR_ALLOW_PRE_PRINTS = ["Yes", "No", "I do not know"].freeze
          validates :allow_pre_prints, inclusion: { in: VALID_VALUES_FOR_ALLOW_PRE_PRINTS }, presence: true

          def available_options_for_allow_pre_prints
            VALID_VALUES_FOR_ALLOW_PRE_PRINTS
          end

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: 'publication_name', values: publication_name)
              repository.update_work_attribute_values!(work: work, key: 'allow_pre_prints', values: allow_pre_prints)
            end
          end

          private

          def publication_name_from_work
            Array.wrap(repository.work_attribute_values_for(work: work, key: 'publication_name')).first
          end

          def allow_pre_prints_from_work
            Array.wrap(repository.work_attribute_values_for(work: work, key: 'allow_pre_prints')).first
          end
        end
      end
    end
  end
end
