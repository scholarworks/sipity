require_relative '../../../forms'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for submitting final step which is completing cataloging.
        class CatalogingCompleteForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            template: Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME,
            attribute_names: [:agree_to_signoff, :oclc_number, :catalog_system_number]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.agree_to_signoff = attributes[:agree_to_signoff]
            self.oclc_number = attributes.fetch(:oclc_number) { oclc_number_from_work }
            self.catalog_system_number = attributes.fetch(:catalog_system_number) { catalog_system_number_from_work }
          end

          include ActiveModel::Validations
          validates :agree_to_signoff, acceptance: { accept: true }
          validates :oclc_number, presence: true
          validates :catalog_system_number, presence: true

          # @param f SimpleFormBuilder
          #
          # @return String
          def render(f:)
            markup = view_context.content_tag('legend', legend)
            markup << f.input(:oclc_number, input_html: { required: 'required' }).html_safe
            markup << f.input(:catalog_system_number, input_html: { required: 'required' }).html_safe
            markup << f.input(
              :agree_to_signoff,
              as: :boolean, inline_label: signoff_agreement, label: false, wrapper_class: 'checkbox',
              input_html: { required: 'required' } # There is no way to add true boolean attributes to simle_form fields.
            ).html_safe
          end

          def legend
            view_context.t('etd/cataloger_signoff', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
          end

          def signoff_agreement
            view_context.t('i_agree', scope: 'sipity/forms.state_advancing_actions.verification.etd/cataloger_signoff').html_safe
          end

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: Models::AdditionalAttribute::OCLC_NUMBER, values: oclc_number)
              repository.update_work_attribute_values!(
                work: work, key: Models::AdditionalAttribute::CATALOG_SYSTEM_NUMBER, values: catalog_system_number
              )
            end
          end

          private

          def agree_to_signoff=(value)
            @agree_to_signoff = PowerConverter.convert_to_boolean(value)
          end

          def view_context
            Draper::ViewContext.current
          end

          def oclc_number_from_work
            repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::OCLC_NUMBER, cardinality: 1)
          end

          def catalog_system_number_from_work
            repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::CATALOG_SYSTEM_NUMBER, cardinality: 1)
          end
        end
      end
    end
  end
end
