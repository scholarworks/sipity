module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for submitting the associated entity to the advisor
        # for signoff.
        class AdvisorSignoffForm < Forms::Etd::AdvisorSignoffForm
          def initialize(work:, repository:, attributes:, processing_action_name:)
            super(attributes.merge(work: work, repository: repository, enrichment_type: processing_action_name))
          end
        end
      end
    end
  end
end
