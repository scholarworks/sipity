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

      def submit(repository:, requested_by:)
        super() do |_f|
          repository.update_work_attribute_values!(
            work: work, key: Models::AdditionalAttribute::CITATION_PREDICATE_NAME, values: citation
          )
          repository.update_work_attribute_values!(
            work: work, key: Models::AdditionalAttribute::CITATION_TYPE_PREDICATE_NAME, values: type
          )
          repository.log_event!(entity: work, user: requested_by, event_name: event_name)
          work
        end
      end

      private

      def event_name
        File.join(self.class.to_s.demodulize.underscore, 'submit')
      end
    end
  end
end
