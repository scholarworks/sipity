module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means for attaching files to the associated work.
      class CollaboratorForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          @collaborators_attributes = attributes[:collaborators_attributes]
        end
      end
    end
  end
end
