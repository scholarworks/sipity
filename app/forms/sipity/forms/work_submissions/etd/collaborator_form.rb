module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Exposes a means for attaching files to the associated work.
        class CollaboratorForm < WorkEnrichments::CollaboratorForm
          def initialize(work:, repository:, attributes:, processing_action_name:)
            super(attributes.merge(work: work, repository: repository, enrichment_type: processing_action_name))
          end
        end
      end
    end
  end
end
