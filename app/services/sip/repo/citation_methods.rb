module Sip
  module Repo
    # Citation related methods
    module CitationMethods
      def citation_already_assigned?(header)
        Support::AdditionalAttributes.values_for(header: header, key: AdditionalAttribute::CITATION_PREDICATE_NAME).any?
      end

      def build_assign_a_citation_form(attributes = {})
        AssignACitationForm.new(attributes)
      end

      def submit_assign_a_citation_form(form)
        form.submit do |f|
          Support::AdditionalAttributes.update!(header: f.header, key: AdditionalAttribute::CITATION_PREDICATE_NAME, values: f.citation)
          Support::AdditionalAttributes.update!(header: f.header, key: AdditionalAttribute::CITATION_TYPE_PREDICATE_NAME, values: f.type)
        end
      end
    end
  end
end
