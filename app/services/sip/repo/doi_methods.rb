module Sip
  module Repo
    # DOI related methods
    module DoiMethods
      def doi_request_is_pending?(header)
        DoiCreationRequest.where(header: header).any?
      end

      def doi_already_assigned?(header)
        AdditionalAttribute.where(header: header, key: AdditionalAttribute::DOI_PREDICATE_NAME).any?
      end

      def build_assign_a_doi_form(attributes = {})
        AssignADoiForm.new(attributes)
      end

      def submit_assign_a_doi_form(form)
        form.submit do |f|
          AdditionalAttribute.create!(header: f.header, key: f.identifier_key, value: f.identifier)
        end
      end

      def build_request_a_doi_form(attributes = {})
        RequestADoiForm.new(attributes)
      end

      def submit_request_a_doi_form(form)
        form.submit do |f|
          AdditionalAttribute.create!(header: f.header, key: AdditionalAttribute::PUBLISHER_PREDICATE_NAME, value: f.publisher)
          if f.publication_date.present?
            AdditionalAttribute.create!(
              header: f.header, key: AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME, value: f.publication_date
            )
          end
          DoiCreationRequest.create!(header: f.header, state: 'request_not_yet_submitted')
        end
      end
    end
  end
end
