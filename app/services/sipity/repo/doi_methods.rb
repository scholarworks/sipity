require 'sipity/jobs'

module Sipity
  module Repo
    # DOI related methods
    module DoiMethods
      def doi_request_is_pending?(header)
        # @todo This query is not entirely correct. It needs to interrogate
        #   the states of the DoiCreationRequest. In this case, I have a leaky
        #   state machine as its enforcement is in
        #   Sipity::Jobs::DoiCreationRequestJob
        Models::DoiCreationRequest.where(header: header).any?
      end

      def find_doi_creation_request(header:)
        Models::DoiCreationRequest.where(header: header).first!
      end

      def find_doi_creation_request_by_id(id)
        # Going to give you the header as part of the find; You'll probably want
        # it.
        Models::DoiCreationRequest.includes(:header).find(id)
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
          submit_doi_creation_request_job!(header: f.header)
        end
      end

      def update_header_doi_creation_request_state!(header:, state:, response_message: nil)
        doi_creation_request = find_doi_creation_request(header: header)
        attributes = { state: get_valid_doi_creation_request_state(state) }
        attributes[:response_message] = response_message if response_message.present?
        doi_creation_request.update(attributes)
      end

      def update_header_with_doi_predicate!(header:, values:)
        Support::AdditionalAttributes.update!(
          header: header, key: Models::AdditionalAttribute::DOI_PREDICATE_NAME, values: values
        )
      end

      def gather_doi_creation_request_metadata(header_id:)
        Services::DoiCreationRequestMetadataGatherer.call(header_id: header_id)
      end

      private

      def get_valid_doi_creation_request_state(state)
        Models::DoiCreationRequest.const_get(state.to_s.upcase)
      end

      def submit_doi_creation_request_job!(header:)
        request = Models::DoiCreationRequest.create!(header: header)
        # TODO: Is this the best way to submit a job?
        # Would it be better to craft a Job submission layer?
        Jobs.submit('doi_creation_request_job', request.id)
        request
      end
    end
  end
end
