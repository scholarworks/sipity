module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means for attaching files to the associated work.
      class AdvisorForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          @advisor_attributes = attributes[:advisor_attributes]
        end
      end
    end
  end
end
