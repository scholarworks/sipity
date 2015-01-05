module Sipity
  # :nodoc:
  module Commands
    # Commands
    module DoiCommands
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::DoiQueries)
      end
      def submit_assign_a_doi_form(form, requested_by:)
        form.submit do |f|
          EventLogCommands.log_event!(entity: f.sip, user: requested_by, event_name: __method__)
          AdditionalAttributeCommands.update_sip_attribute_values!(
            sip: f.sip, key: f.identifier_key, values: f.identifier
          )
        end
      end

      def submit_request_a_doi_form(form, requested_by:)
        form.submit do |f|
          AdditionalAttributeCommands.update_sip_attribute_values!(
            sip: f.sip, key: Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME, values: f.publisher
          )
          AdditionalAttributeCommands.update_sip_publication_date!(sip: f.sip, publication_date: f.publication_date)
          EventLogCommands.log_event!(entity: f.sip, user: requested_by, event_name: __method__)
          submit_doi_creation_request_job!(sip: f.sip)
        end
      end

      def update_sip_doi_creation_request_state!(sip:, state:, response_message: nil)
        doi_creation_request = find_doi_creation_request(sip: sip)
        attributes = { state: state.to_s.downcase }
        attributes[:response_message] = response_message if response_message.present?
        doi_creation_request.update(attributes)
      end

      def update_sip_with_doi_predicate!(sip:, values:)
        AdditionalAttributeCommands.update_sip_attribute_values!(
          sip: sip, key: Models::AdditionalAttribute::DOI_PREDICATE_NAME, values: values
        )
      end

      private

      def submit_doi_creation_request_job!(sip:)
        request = Models::DoiCreationRequest.create!(sip: sip)
        Jobs.submit('doi_creation_request_job', sip.id)
        request
      end
    end
    private_constant :DoiCommands
  end
end
