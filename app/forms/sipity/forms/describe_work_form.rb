module Sipity
  module Forms
    # Responsible for capturing and validating information for describe.
    class DescribeWorkForm < BaseForm
      self.policy_enforcer = Policies::EnrichWorkByFormSubmissionPolicy

      def initialize(attributes = {})
        puts "initialize"
        @work = attributes.fetch(:work)
        @abstract = attributes[:abstract]
      end
      attr_accessor :abstract
      attr_reader :work

      validates :abstract, presence: true
      validates :work, presence: true
    end
  end
end
