module Sipity
  module Forms
    module Etd
      module WorkSubmissions
        # Responsible for capturing comments and forwarding them on to the
        # student.
        class GradSchoolRequestsChangeForm < Forms::Etd::GradSchoolRequestsChangeForm
          def initialize(work:, repository:, attributes:, processing_action_name:)
            super(attributes.merge(work: work, repository: repository, enrichment_type: processing_action_name))
          end
        end
      end
    end
  end
end
