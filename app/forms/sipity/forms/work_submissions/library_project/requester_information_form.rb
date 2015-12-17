require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'sipity/forms'
module Sipity
  module Forms
    module WorkSubmissions
      module LibraryProject
        # Capture additional requesting information
        class RequesterInformationForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:library_program_name]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.library_program_name = attributes.fetch(:library_program_name) { library_program_name_from_work }
          end

          public

          include ActiveModel::Validations
          validates :library_program_name, presence: true, inclusion: { in: :library_program_name_for_select }

          LIBRARY_PROGRAM_FOR_SELECT = [
            "Academic Outreach and Engagement",
            "Administrative and Central Resources",
            "Arts and Humanities Research Services",
            "Digital Initiatives and Scholarship",
            "Information Technology",
            "Resource Acquisitions and Discovery",
            "Science Engineering Social Science and Business"
          ].freeze

          def library_program_name_for_select
            LIBRARY_PROGRAM_FOR_SELECT
          end

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: 'library_program_name', values: library_program_name)
            end
          end

          private

          def library_program_name_from_work
            repository.work_attribute_values_for(work: work, key: 'library_program_name', cardinality: 1)
          end
        end
      end
    end
  end
end
