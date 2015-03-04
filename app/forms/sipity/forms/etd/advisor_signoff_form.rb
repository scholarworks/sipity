module Sipity
  module Forms
    module Etd
      # Responsible for submitting the associated entity to the advisor
      # for signoff.
      class AdvisorSignoffForm < Forms::StateAdvancingAction
        def initialize(attributes = {})
          super
          @signoff_service = attributes.fetch(:signoff_service) { default_signoff_service }
        end

        attr_reader :signoff_service

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
      end
    end
  end
end
