module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Exposes a means defining the thesis defense date todo item.
        class DefenseDateForm < WorkEnrichments::DefenseDateForm
          def initialize(work:, repository:, attributes:, processing_action_name:)
            super(attributes.merge(work: work, repository: repository, enrichment_type: processing_action_name))
          end
        end
      end
    end
  end
end
