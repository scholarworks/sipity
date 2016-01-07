require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for capturing and validating information related to the author.
        class AuthorForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:author_name]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.author_name = attributes.fetch(:author_name) { author_name_from_work }
          end

          include ActiveModel::Validations
          validates :author_name, presence: true

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: 'author_name', values: author_name)
            end
          end

          private

          def author_name_from_work
            repository.work_attribute_values_for(work: work, key: 'author_name', cardinality: 1)
          end
        end
      end
    end
  end
end
