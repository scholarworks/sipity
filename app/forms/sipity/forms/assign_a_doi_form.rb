module Sipity
  module Forms
    # Responsible for capturing and validating the assignment of a DOI that
    # already exists but has not yet been assigned to the SIP
    class AssignADoiForm < BaseForm
      self.policy_enforcer = Policies::EnrichWorkByFormSubmissionPolicy

      def initialize(attributes = {})
        self.work = attributes.fetch(:work)
        self.identifier = attributes.fetch(:identifier, nil)
        @enrichment_type = attributes.fetch(:enrichment_type, default_enrichment_type)
      end

      attr_reader :enrichment_type
      attr_accessor :work, :identifier
      private(:work=) # Adding parenthesis because Beautify ruby was going crazy

      validates :work, presence: true
      validates :identifier, presence: true

      # TODO: Get this out of here. There is an object that is a better owner of
      # this method. But for now it is here based on a view implementation.
      def assign_a_doi_form
        self
      end

      def identifier_key
        Models::AdditionalAttribute::DOI_PREDICATE_NAME
      end

      # TODO: Get this out of here. There is an object that is a better owner of
      # this method. But for now it is here based on a view implementation.
      def request_a_doi_form
        RequestADoiForm.new(work: work)
      end

      private

      def default_enrichment_type
        'assign_a_doi'
      end
    end
  end
end
