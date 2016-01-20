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
            attribute_names: [:publication_name, :submission_accepted_for_publication, :submitted_for_publication]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.publication_name = attributes.fetch(:publication_name) { publication_name_from_work }
            self.submission_accepted_for_publication = attributes.fetch(:submission_accepted_for_publication) do
              submission_accepted_for_publication_from_work
            end
            self.submitted_for_publication = attributes.fetch(:submitted_for_publication) { submitted_for_publication_from_work }
          end

          include ActiveModel::Validations
          include Hydra::Validations
          validates :publication_name, presence: { if: :submission_accepted_for_publication? }
          validates(
            :submission_accepted_for_publication,
            inclusion: { in: :possible_submission_accepted_for_publication, if: :submitted_for_publication? }
          )

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: 'publication_name', values: publication_name)
              repository.update_work_attribute_values!(work: work, key: 'submitted_for_publication', values: submitted_for_publication)
              repository.update_work_attribute_values!(
                work: work, key: 'submission_accepted_for_publication', values: submission_accepted_for_publication
              )
            end
          end

          def possible_submission_accepted_for_publication
            ['Yes', 'No', 'Pending']
          end

          def submission_accepted_for_publication?
            return false unless submission_accepted_for_publication.present?
            return false if submission_accepted_for_publication == 'No'
            true
          end

          alias submitted_for_publication? submitted_for_publication

          private

          def publication_name_from_work
            Array.wrap(repository.work_attribute_values_for(work: work, key: 'publication_name', cardinality: :many))
          end

          def submission_accepted_for_publication_from_work
            repository.work_attribute_values_for(work: work, key: 'submission_accepted_for_publication', cardinality: 1)
          end

          def submitted_for_publication_from_work
            repository.work_attribute_values_for(work: work, key: 'submitted_for_publication', cardinality: 1)
          end

          def submitted_for_publication=(input)
            @submitted_for_publication = PowerConverter.convert(input, to: :boolean)
          end
        end
      end
    end
  end
end
