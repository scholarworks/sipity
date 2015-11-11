require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for capturing and validating information for describe.
        class DescribeForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:title, :abstract, :alternate_title]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.title = attributes.fetch(:title) { title_from_work }
            self.abstract = attributes.fetch(:abstract) { abstract_from_work }
            self.alternate_title = attributes.fetch(:alternate_title) { alternate_title_from_work }
          end

          include ActiveModel::Validations
          validates :title, presence: true
          validates :abstract, presence: true
          validates :work, presence: true
          validates :requested_by, presence: true

          def submit
            processing_action_form.submit do
              repository.update_work_title!(work: work, title: title)
              repository.update_work_attribute_values!(work: work, key: 'abstract', values: abstract)
              repository.update_work_attribute_values!(work: work, key: 'alternate_title', values: alternate_title)
            end
          end

          private

          include Conversions::SanitizeHtml
          def title=(value)
            @title = sanitize_html(value)
          end

          def abstract=(value)
            @abstract = sanitize_html(value)
          end

          def alternate_title=(value)
            @alternate_title = sanitize_html(value) { nil }
          end

          def abstract_from_work
            repository.work_attribute_values_for(work: work, key: 'abstract', cardinality: 1)
          end

          def alternate_title_from_work
            repository.work_attribute_values_for(work: work, key: 'alternate_title', cardinality: 1)
          end

          def title_from_work
            work.title
          end
        end
      end
    end
  end
end
