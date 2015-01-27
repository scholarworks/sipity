module Sipity
  module Forms
    # The generalized work enrichment form. It is unlikely that you will be able
    # to use this directly.
    class WorkEnrichmentForm < BaseForm
      # TODO: I do not believe that this is the correct policy. We need a policy
      #   that will verify the state of the work and whether the enrichment can
      #   happen.
      self.policy_enforcer = Policies::EnrichWorkByFormSubmissionPolicy

      def initialize(attributes = {})
        @work = attributes.fetch(:work)
        @enrichment_type = attributes.fetch(:enrichment_type) { 'attach' }
      end

      attr_reader :work, :enrichment_type

      validates :work, presence: true

      def submit(repository:, requested_by:)
        return false unless valid?
        save(repository: repository, requested_by: requested_by)
      end

      private

      def save(repository:, requested_by:)
        yield if block_given?
        repository.mark_work_todo_item_as_done(work: work, enrichment_type: enrichment_type)
        repository.log_event!(entity: work, user: requested_by, event_name: event_name)
        work
      end

      def event_name
        File.join(self.class.to_s.underscore.sub('sipity/forms/', ''), 'submit')
      end
    end
  end
end
