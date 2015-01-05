module Sipity
  module Forms
    # Responsible for capturing and validating information for citation creation.
    class AssignACitationForm < BaseForm
      self.policy_enforcer = Policies::EnrichSipByFormSubmissionPolicy

      def initialize(attributes = {})
        @sip = attributes.fetch(:sip)
        @type, @citation = attributes.values_at(:type, :citation)
      end
      attr_accessor :type, :citation
      attr_reader :sip

      validates :sip, presence: true
      validates :citation, presence: true
      validates :type, presence: true
    end
  end
end
