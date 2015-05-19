module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Exposes a means of assigning an access policy to each of the related
        # items.
        class AccessPolicyForm < WorkEnrichments::AccessPolicyForm
          def initialize(work:, repository:, attributes:, processing_action_name:)
            super(attributes.merge(work: work, repository: repository, enrichment_type: processing_action_name))
          end
        end
      end
    end
  end
end
