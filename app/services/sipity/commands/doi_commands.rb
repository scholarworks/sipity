module Sipity
  module Commands
    # Commands
    module DoiCommands
      def submit_assign_a_doi_form(form, requested_by:)
        form.submit do |f|
          EventLogCommands.log_event!(entity: f.header, user: requested_by, event_name: __method__)
          RepositoryMethods::AdditionalAttributeMethods::Commands.update_header_attribute_values!(
            header: f.header, key: f.identifier_key, values: f.identifier
          )
        end
      end

      def submit_request_a_doi_form(form, requested_by:)
        form.submit do |f|
          RepositoryMethods::AdditionalAttributeMethods::Commands.update_header_attribute_values!(
            header: f.header, key: Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME, values: f.publisher
          )
          RepositoryMethods::AdditionalAttributeMethods::Commands.update_header_publication_date!(header: f.header, publication_date: f.publication_date)
          EventLogCommands.log_event!(entity: f.header, user: requested_by, event_name: __method__)
          submit_doi_creation_request_job!(header: f.header)
        end
      end

      def update_header_doi_creation_request_state!(header:, state:, response_message: nil)
        doi_creation_request = find_doi_creation_request(header: header)
        attributes = { state: state.to_s.downcase }
        attributes[:response_message] = response_message if response_message.present?
        doi_creation_request.update(attributes)
      end

      def update_header_with_doi_predicate!(header:, values:)
        RepositoryMethods::AdditionalAttributeMethods::Commands.update_header_attribute_values!(
          header: header, key: Models::AdditionalAttribute::DOI_PREDICATE_NAME, values: values
        )
      end

      private

      def submit_doi_creation_request_job!(header:)
        request = Models::DoiCreationRequest.create!(header: header)
        Jobs.submit('doi_creation_request_job', header.id)
        request
      end
    end
  end
end
