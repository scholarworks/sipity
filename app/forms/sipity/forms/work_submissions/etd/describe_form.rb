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

          def initialize(work:, attributes: {}, **keywords)
            self.work = work
            self.processing_action_form = ProcessingForm.new(form: self, **keywords)
            self.title = attributes.fetch(:title) { title_from_work }
            self.abstract = attributes.fetch(:abstract) { abstract_from_work }
            self.alternate_title = attributes.fetch(:alternate_title) { alternate_title_from_work }
          end

          include ActiveModel::Validations
          validates :title, presence: true
          validates :abstract, presence: true
          validates :work, presence: true

          private

          def save(*)
            repository.update_work_title!(work: work, title: title)
            repository.update_work_attribute_values!(work: work, key: 'abstract', values: abstract)
            repository.update_work_attribute_values!(work: work, key: 'alternate_title', values: alternate_title)
          end

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
            repository.work_attribute_values_for(work: work, key: 'abstract').first
          end

          def alternate_title_from_work
            repository.work_attribute_values_for(work: work, key: 'alternate_title').first
          end

          def title_from_work
            return '' unless work
            work.title
          end
        end
      end
    end
  end
end
