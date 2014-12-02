module Sip
  module Repo
    # Citation related methods
    module CitationMethods
      def citation_already_assigned?(header)
        AdditionalAttribute.where(header: header, key: AdditionalAttribute::CITATION_PREDICATE_NAME).any?
      end

      def build_assign_a_citation_form(attributes = {})
        AssignACitationForm.new(attributes)
      end

      def submit_assign_a_citation_form(form)
        form.submit do |f|
          AdditionalAttribute.create!(header: f.header, key: AdditionalAttribute::CITATION_PREDICATE_NAME, value: f.citation)
          AdditionalAttribute.create!(header: f.header, key: AdditionalAttribute::CITATION_TYPE_PREDICATE_NAME, value: f.type)
        end
      end
    end
  end
end
