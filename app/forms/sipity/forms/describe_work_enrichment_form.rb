module Sipity
  module Forms
    # Responsible for capturing and validating information for describe.
    class DescribeWorkEnrichmentForm < BaseForm
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

      def submit(repository:, requested_by:)
        super() do |_f|
          repository.update_work_attribute_values!(work: work, key: 'abstract', values: abstract)
          repository.mark_work_todo_item_as_done(work: work, enrichment_type: enrichment_type)
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
