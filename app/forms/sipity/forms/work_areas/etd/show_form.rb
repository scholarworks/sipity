module Sipity
  module Forms
    module WorkAreas
      module Etd
        # Responsible for "showing" an ETD Work Area.
        class ShowForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::WorkArea, attribute_names: [:processing_state, :order_by]
          )

          def initialize(work_area:, attributes: {}, **keywords)
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.work_area = work_area
            self.processing_state = attributes[:processing_state]
            self.order_by = attributes.fetch(:order_by) { default_order_by }
          end

          # @note There is a correlation to the Parameters::SearchCriteriaForWorksParameter
          #   object
          def input_name_for_select_processing_state
            "#{model_name.param_key}[processing_state]"
          end

          # @note There is a correlation to the Parameters::SearchCriteriaForWorksParameter
          #   object
          def input_name_for_select_sort_order
            "#{model_name.param_key}[order_by]"
          end

          def processing_states_for_select
            repository.processing_state_names_for_select_within_work_area(work_area: work_area)
          end

          def order_by_options_for_select
            Parameters::SearchCriteriaForWorksParameter.order_by_options_for_select
          end

          include ActiveModel::Validations

          delegate :name, :slug, to: :work_area

          private

          include GuardInterfaceExpectation
          def work_area=(input)
            guard_interface_expectation!(input, :name, :slug)
            @work_area = input
          end

          def default_order_by
            Parameters::SearchCriteriaForWorksParameter.default_order_by
          end
        end
      end
    end
  end
end
