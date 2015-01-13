module Sipity
  module Forms
    # Responsible for capturing and validating information for citation creation.
    class AssignACitationForm < BaseForm
      self.policy_enforcer = Policies::EnrichWorkByFormSubmissionPolicy

      def initialize(attributes = {})
        @work = attributes.fetch(:work)
        @type, @citation = attributes.values_at(:type, :citation)
      end
      attr_accessor :type, :citation
      attr_reader :work

      validates :work, presence: true
      validates :citation, presence: true
      validates :type, presence: true
    end
  end
end
