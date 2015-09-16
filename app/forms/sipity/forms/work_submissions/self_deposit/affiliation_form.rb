require 'active_support/core_ext/array/wrap'

module Sipity
  module Forms
    module WorkSubmissions
      module SelfDeposit
        # Responsible for capturing and validating information for affiliation.
        class AffiliationForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:organization, :affiliation]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.affiliation = attributes.fetch(:affiliation) { affiliation_from_work }
            self.organization = attributes.fetch(:organization) { organization_from_work }
          end

          include ActiveModel::Validations
          validates :affiliation, presence: true
          validates :organization, presence: true

          def available_affiliations
            repository.get_controlled_vocabulary_values_for_predicate_name(name: 'affiliation')
          end

          def available_organizations
            repository.get_controlled_vocabulary_values_for_predicate_name(name: 'organization')
          end

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: 'affiliation', values: affiliation)
              repository.update_work_attribute_values!(work: work, key: 'organization', values: organization)
            end
          end

          private

          def affiliation=(values)
            @affiliation = to_array_without_empty_values(values)
          end

          def organization=(values)
            @organization = to_array_without_empty_values(values)
          end

          def affiliation_from_work
            repository.work_attribute_values_for(work: work, key: 'affiliation')
          end

          def organization_from_work
            repository.work_attribute_values_for(work: work, key: 'organization')
          end

          def to_array_without_empty_values(value)
            Array.wrap(value).select(&:present?)
          end
        end
      end
    end
  end
end
