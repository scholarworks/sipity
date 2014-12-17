module Sipity
  module RepositoryMethods
    # Citation related methods
    module CitationMethods
      def citation_already_assigned?(header)
        Support::AdditionalAttributes.values_for(header: header, key: Models::AdditionalAttribute::CITATION_PREDICATE_NAME).any?
      end

      def build_assign_a_citation_form(attributes = {})
        Forms::AssignACitationForm.new(attributes)
      end

      def submit_assign_a_citation_form(form, requested_by:)
        form.submit do |f|
          Support::AdditionalAttributes.update!(
            header: f.header, key: Models::AdditionalAttribute::CITATION_PREDICATE_NAME, values: f.citation
          )
          Support::AdditionalAttributes.update!(
            header: f.header, key: Models::AdditionalAttribute::CITATION_TYPE_PREDICATE_NAME, values: f.type
          )
          Models::EventLog.create!(entity: f.header, user: requested_by, event_name: __method__)
          f.header
        end
      end
    end
    private_constant :CitationMethods
  end
end
