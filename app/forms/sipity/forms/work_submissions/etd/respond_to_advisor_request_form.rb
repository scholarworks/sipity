module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for capturing a student's comment and forwarding them on to
        # the advisors.
        class RespondToAdvisorRequestForm < Forms::Etd::RespondToAdvisorRequestForm
          def initialize(work:, repository:, attributes:, processing_action_name:)
            super(attributes.merge(work: work, repository: repository, enrichment_type: processing_action_name))
          end
        end
      end
    end
  end
end
