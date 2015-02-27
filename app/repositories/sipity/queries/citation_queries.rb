module Sipity
  module Queries
    # Queries
    module CitationQueries
      def citation_already_assigned?(work)
        AdditionalAttributeQueries.work_attribute_values_for(
          work: work, key: Models::AdditionalAttribute::CITATION_PREDICATE_NAME
        ).any?
      end

      def build_assign_a_citation_form(attributes = {})
        Forms::AssignACitationForm.new(attributes.merge(repository: self))
      end
    end
  end
end
