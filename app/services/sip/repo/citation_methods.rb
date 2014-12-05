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

      def submit_assign_a_citation_form(form, requested_by: nil)
        form.submit do |f|
          Support::AdditionalAttributes.update!(header: f.header, key: AdditionalAttribute::CITATION_PREDICATE_NAME, values: f.citation)
          Support::AdditionalAttributes.update!(header: f.header, key: AdditionalAttribute::CITATION_TYPE_PREDICATE_NAME, values: f.type)
          EventLog.create!(subject: f.header, user: requested_by, event_name: 'submit_assign_a_citation_form') if requested_by
          true
        end
      end
    end
  end
end
