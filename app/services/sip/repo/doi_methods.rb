module Sip
  module Repo
    # DOI related methods
    module DoiMethods
      def doi_request_is_pending?(header)
        DoiCreationRequest.where(header: header).any?
      end

      def doi_already_assigned?(header)
        Support::AdditionalAttributes.values_for(header: header, key: AdditionalAttribute::DOI_PREDICATE_NAME).any?
      end

      def build_assign_a_doi_form(attributes = {})
        AssignADoiForm.new(attributes)
      end

      def submit_assign_a_doi_form(form)
        form.submit do |f|
          Support::AdditionalAttributes.update!(header: f.header, key: f.identifier_key, values: f.identifier)
        end
      end

      def build_request_a_doi_form(attributes = {})
        RequestADoiForm.new(attributes)
      end

      def submit_request_a_doi_form(form)
        form.submit do |f|
          Support::AdditionalAttributes.update!(header: f.header, key: AdditionalAttribute::PUBLISHER_PREDICATE_NAME, values: f.publisher)
          Support::PublicationDate.create!(header: f.header, publication_date: f.publication_date)
          DoiCreationRequest.create!(header: f.header, state: 'request_not_yet_submitted')
        end
      end
    end
  end
end
