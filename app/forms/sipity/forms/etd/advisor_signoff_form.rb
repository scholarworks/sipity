module Sipity
  module Forms
    module Etd
      # Responsible for submitting the associated entity to the advisor
      # for signoff.
      class AdvisorSignoffForm < ProcessingActionForm
        def initialize(attributes = {})
          super
          self.action = attributes.fetch(:processing_action_name) { default_processing_action_name }
          @signoff_service = attributes.fetch(:signoff_service) { default_signoff_service }
        end

        attr_reader :action, :signoff_service

        def processing_action_name
          action.name
        end

        delegate :resulting_strategy_state, to: :action

        private

        private :signoff_service
        def default_signoff_service
          Services::AdvisorSignsOff
        end

        def save(requested_by:)
          super do
            signoff_service.call(form: self, requested_by: requested_by, repository: repository)
          end
        end

        def enrichment_type
          self.class.to_s.demodulize.underscore.sub(/_form\Z/i, '')
        end
        alias_method :default_processing_action_name, :enrichment_type

        include Conversions::ConvertToProcessingAction
        def action=(value)
          @action = convert_to_processing_action(value, scope: to_processing_entity)
        end
      end
    end
  end
end
