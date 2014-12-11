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

      def submit_assign_a_doi_form(form, requested_by:)
        form.submit do |f|
          Models::EventLog.create!(entity: f.header, user: requested_by, event_name: __method__)
          Support::AdditionalAttributes.update!(header: f.header, key: f.identifier_key, values: f.identifier)
        end
      end

      def build_request_a_doi_form(attributes = {})
        Forms::RequestADoiForm.new(attributes)
      end

      def submit_request_a_doi_form(form, requested_by:)
        form.submit do |f|
          Support::AdditionalAttributes.update!(
            header: f.header, key: Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME, values: f.publisher
          )
          Support::PublicationDate.create!(header: f.header, publication_date: f.publication_date)
          Models::EventLog.create!(entity: f.header, user: requested_by, event_name: __method__)
          request = Models::DoiCreationRequest.create!(header: f.header, state: Models::DoiCreationRequest::REQUEST_NOT_YET_SUBMITTED)
          # TODO: Is this the best way to submit a job?
          # Would it be better to craft a Job submission layer?
          Jobs::DoiCreationRequestJob.submit(request.id)
          request
        end
      end
    end
  end
end
