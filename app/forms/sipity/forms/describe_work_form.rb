module Sipity
  module Forms
    # Responsible for capturing and validating information for describe.
    class DescribeWorkForm < BaseForm
      self.policy_enforcer = Policies::EnrichWorkByFormSubmissionPolicy

      def initialize(attributes = {})
        @work = attributes.fetch(:work)
        @enrichment_type = attributes.fetch(:enrichment_type) { 'describe' }
        @abstract = attributes[:abstract]
      end
      attr_accessor :abstract
      attr_reader :work, :enrichment_type

      validates :abstract, presence: true
      validates :work, presence: true
    end
  end
end
