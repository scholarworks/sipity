require 'sipity/jobs'

module Sipity
  # :nodoc:
  module RepositoryMethods
    # DOI related methods
    module DoiMethods
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries)
        base.send(:include, Commands)
      end

      # Queries
      module Queries
        def doi_request_is_pending?(header)
          # @todo This query is not entirely correct. It needs to interrogate
          #   the states of the DoiCreationRequest. In this case, I have a leaky
          #   state machine as its enforcement is in
          #   Sipity::Jobs::DoiCreationRequestJob
          Models::DoiCreationRequest.where(header: header).any?
        end

        def find_doi_creation_request(header:)
          # Going to give you the header as part of the find; You'll probably want
          # it.
          Models::DoiCreationRequest.includes(:header).where(header: header).first!
        end

        def doi_already_assigned?(header)
          AdditionalAttributeMethods.header_attribute_values_for(
            header: header, key: Models::AdditionalAttribute::DOI_PREDICATE_NAME
          ).any?
        end

        def build_assign_a_doi_form(attributes = {})
          Forms::AssignADoiForm.new(attributes)
        end

        def gather_doi_creation_request_metadata(header:)
          Services::DoiCreationRequestMetadataGatherer.call(header: header)
        end

        def build_request_a_doi_form(attributes = {})
          Forms::RequestADoiForm.new(attributes)
        end
      end

      # Commands
      module Commands

        def submit_assign_a_doi_form(form, requested_by:)
          form.submit do |f|
            EventLogMethods::Commands.log_event!(entity: f.header, user: requested_by, event_name: __method__)
            AdditionalAttributeMethods.update_header_attribute_values!(header: f.header, key: f.identifier_key, values: f.identifier)
          end
        end

        def submit_request_a_doi_form(form, requested_by:)
          form.submit do |f|
            AdditionalAttributeMethods.update_header_attribute_values!(
              header: f.header, key: Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME, values: f.publisher
            )
            AdditionalAttributeMethods.update_header_publication_date!(header: f.header, publication_date: f.publication_date)
            EventLogMethods::Commands.log_event!(entity: f.header, user: requested_by, event_name: __method__)
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
          AdditionalAttributeMethods.update_header_attribute_values!(
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
    private_constant :DoiMethods
  end
end
