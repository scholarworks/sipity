module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for exposing ability for someone to signoff on the work
        # on behalf of someone else.
        class SignoffOnBehalfOfForm < Forms::Etd::SignoffOnBehalfOfForm
          def initialize(work:, repository:, attributes:, processing_action_name:)
            super(attributes.merge(work: work, repository: repository, enrichment_type: processing_action_name))
          end
        end
      end
    end
  end
end
