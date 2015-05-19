module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for capturing advisor comments and forwarding them on to
        # the student.
        class AdvisorRequestsChangeForm < Forms::Etd::AdvisorRequestsChangeForm
          def initialize(work:, repository:, attributes:, processing_action_name:)
            super(attributes.merge(work: work, repository: repository, enrichment_type: processing_action_name))
          end
        end
      end
    end
  end
end
