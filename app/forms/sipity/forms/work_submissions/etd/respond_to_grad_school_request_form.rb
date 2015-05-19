module Sipity
  module Forms
    module Etd
      module WorkSubmissions
        # Responsible for capturing a student's comment and forwarding them on to
        # the grad school.
        class RespondToGradSchoolRequestForm < Forms::Etd::RespondToGradSchoolRequestForm
          def initialize(work:, repository:, attributes:, processing_action_name:)
            super(attributes.merge(work: work, repository: repository, enrichment_type: processing_action_name))
          end
        end
      end
    end
  end
end
