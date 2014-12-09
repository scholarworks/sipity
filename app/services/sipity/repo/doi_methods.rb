module Sipity
  module Repo
    # DOI related methods
    module DoiMethods
      def doi_request_is_pending?(header)
        Models::DoiCreationRequest.where(header: header).any?
      end

      def doi_already_assigned?(header)
        Support::AdditionalAttributes.values_for(
          header: header, key: Models::AdditionalAttribute::DOI_PREDICATE_NAME
        ).any?
      end

      def build_assign_a_doi_form(attributes = {})
        Forms::AssignADoiForm.new(attributes)
      end

      def submit_assign_a_doi_form(form, requested_by: nil)
        form.submit do |f|
          Models::EventLog.create!(subject: f.header, user: requested_by, event_name: __method__) if requested_by
          Support::AdditionalAttributes.update!(header: f.header, key: f.identifier_key, values: f.identifier)
        end
      end

      def build_request_a_doi_form(attributes = {})
        Forms::RequestADoiForm.new(attributes)
      end

      def submit_request_a_doi_form(form, requested_by: nil)
        form.submit do |f|
          Support::AdditionalAttributes.update!(
            header: f.header, key: Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME, values: f.publisher
          )
          Support::PublicationDate.create!(header: f.header, publication_date: f.publication_date)
          Models::EventLog.create!(subject: f.header, user: requested_by, event_name: __method__) if requested_by
          # TODO: Remove magic string
          Models::DoiCreationRequest.create!(header: f.header, state: Models::DoiCreationRequest::REQUEST_NOT_YET_SUBMITTED)
        end
      end
    end
  end
end
