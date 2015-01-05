module Sipity
  module Queries
    # Queries
    module DoiQueries
      def doi_request_is_pending?(sip)
        # @todo This query is not entirely correct. It needs to interrogate
        #   the states of the DoiCreationRequest. In this case, I have a leaky
        #   state machine as its enforcement is in
        #   Sipity::Jobs::DoiCreationRequestJob
        Models::DoiCreationRequest.where(sip: sip).any?
      end

      def find_doi_creation_request(sip:)
        # Going to give you the sip as part of the find; You'll probably want
        # it.
        Models::DoiCreationRequest.includes(:sip).where(sip: sip).first!
      end

      def doi_already_assigned?(sip)
        AdditionalAttributeQueries.sip_attribute_values_for(
          sip: sip, key: Models::AdditionalAttribute::DOI_PREDICATE_NAME
        ).any?
      end

      def build_assign_a_doi_form(attributes = {})
        Forms::AssignADoiForm.new(attributes)
      end

      def gather_doi_creation_request_metadata(sip:)
        Services::DoiCreationRequestMetadataGatherer.call(sip: sip)
      end

      def build_request_a_doi_form(attributes = {})
        Forms::RequestADoiForm.new(attributes)
      end
    end
  end
end
