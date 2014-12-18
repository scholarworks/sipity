module Sipity
  module Queries
    # Queries
    module CitationQueries
      def citation_already_assigned?(header)
        RepositoryMethods::AdditionalAttributeMethods::Queries.header_attribute_values_for(
          header: header, key: Models::AdditionalAttribute::CITATION_PREDICATE_NAME
        ).any?
      end

      def build_assign_a_citation_form(attributes = {})
        Forms::AssignACitationForm.new(attributes)
      end
    end
  end
end
