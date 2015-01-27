module Sipity
  module Forms
    # The generalized work event trigger form.
    class WorkEventTriggerForm < BaseForm
      # TODO: I do not believe that this is the correct policy. We need a policy
      #   that will verify the state of the work and whether the event trigger
      #   can happen.
      self.policy_enforcer = Policies::EnrichWorkByFormSubmissionPolicy

      def initialize(attributes = {})
        @work = attributes.fetch(:work)
        @event_name = attributes.fetch(:event_name) { 'standard' }
      end

      attr_reader :work, :event_name

      validates :work, presence: true
      validates :event_name, presence: true

      def submit(repository:, requested_by:)
        return false unless valid?
        save(repository: repository, requested_by: requested_by)
      end

      private

      def save(repository:, requested_by:)
        yield if block_given?
        repository.log_event!(entity: work, user: requested_by, event_name: logged_event_name)
        work
      end

      def logged_event_name
        File.join(self.class.to_s.underscore.sub('sipity/forms/', ''), 'submit', event_name)
      end
    end
  end
end
