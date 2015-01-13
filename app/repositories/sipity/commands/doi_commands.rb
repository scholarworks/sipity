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
          EventLogCommands.log_event!(entity: f.work, user: requested_by, event_name: __method__)
          AdditionalAttributeCommands.update_work_attribute_values!(
            work: f.work, key: f.identifier_key, values: f.identifier
          )
        end
      end

      def submit_request_a_doi_form(form, requested_by:)
        form.submit do |f|
          AdditionalAttributeCommands.update_work_attribute_values!(
            work: f.work, key: Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME, values: f.publisher
          )
          AdditionalAttributeCommands.update_work_publication_date!(work: f.work, publication_date: f.publication_date)
          EventLogCommands.log_event!(entity: f.work, user: requested_by, event_name: __method__)
          submit_doi_creation_request_job!(work: f.work)
        end
      end

      def update_work_doi_creation_request_state!(work:, state:, response_message: nil)
        doi_creation_request = find_doi_creation_request(work: work)
        attributes = { state: state.to_s.downcase }
        attributes[:response_message] = response_message if response_message.present?
        doi_creation_request.update(attributes)
      end

      def update_work_with_doi_predicate!(work:, values:)
        AdditionalAttributeCommands.update_work_attribute_values!(
          work: work, key: Models::AdditionalAttribute::DOI_PREDICATE_NAME, values: values
        )
      end

      private

      def submit_doi_creation_request_job!(work:)
        request = Models::DoiCreationRequest.create!(work: work)
        Jobs.submit('doi_creation_request_job', work.id)
        request
      end
    end
    private_constant :DoiCommands
  end
end
