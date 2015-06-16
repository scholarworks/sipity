module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for capturing and validating publication and patent
        # intentions
        class PublishingAndPatentingIntentForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:work_publication_strategy, :work_patent_strategy]
          )

          def initialize(work:, attributes: {}, **keywords)
            self.work = work
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.publication_and_patenting_intent_extension = publication_and_patenting_intent_extension_builder.new(
              form: self, repository: repository
            )
            self.work_publication_strategy = attributes.fetch(:work_publication_strategy) { work_publication_strategy_from_work }
            self.work_patent_strategy = attributes.fetch(:work_patent_strategy) { work_patent_strategy_from_work }
          end

          delegate(
            :work_patent_strategy, :work_patent_strategy=, :work_patent_strategy_from_work, :work_patent_strategies_for_select,
            :possible_work_patent_strategies, :persist_work_patent_strategy,
            :work_publication_strategy, :work_publication_strategy=, :work_publication_strategy_from_work,
            :work_publication_strategies_for_select, :possible_work_publication_strategies, :persist_work_publication_strategy,
            to: :publication_and_patenting_intent_extension
          )

          private(
            :work_patent_strategy=, :work_patent_strategy_from_work, :possible_work_patent_strategies, :persist_work_patent_strategy,
            :work_publication_strategy=, :work_publication_strategy_from_work, :possible_work_publication_strategies,
            :persist_work_publication_strategy
          )

          include ActiveModel::Validations
          validates :work_patent_strategy, presence: true, inclusion: { in: :possible_work_patent_strategies }
          validates :work_publication_strategy, presence: true, inclusion: { in: :possible_work_publication_strategies }
          validates :work, presence: true

          def submit(requested_by:)
            processing_action_form.submit(requested_by: requested_by) do
              persist_work_publication_strategy
              persist_work_patent_strategy
            end
          end

          private

          attr_accessor :publication_and_patenting_intent_extension

          def publication_and_patenting_intent_extension_builder
            Forms::ComposableElements::PublishingAndPatentingIntentExtension
          end
        end
      end
    end
  end
end
