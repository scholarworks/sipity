module Sipity
  module Forms
    module WorkAreas
      module Etd
        # Responsible for "showing" an ETD Work Area.
        class ShowForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::WorkArea, attribute_names: :work_processing_state
          )

          def initialize(work_area:, attributes: {}, **keywords)
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.work_area = work_area
            self.work_processing_state = attributes[:work_processing_state]
          end

          # The form convention is that parameters are wrapped in the param_key
          def input_name_for_select_work_processing_state
            "#{model_name.param_key}[work_processing_state]"
          end

          def work_processing_states_for_select
            repository.processing_state_names_for_select_within_work_area(work_area: work_area)
          end

          include ActiveModel::Validations

          delegate :name, :slug, to: :work_area

          private

          include GuardInterfaceExpectation
          def work_area=(input)
            guard_interface_expectation!(input, :name, :slug)
            @work_area = input
          end
        end
      end
    end
  end
end
