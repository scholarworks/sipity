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
        @event_receiver = attributes.fetch(:event_receiver) { default_event_receiver }
        @event_name = attributes.fetch(:event_name) { 'default' }
      end

      attr_reader :work, :event_name, :event_receiver

      validates :work, presence: true
      validates :event_name, presence: true

      def submit(repository:, requested_by:)
        return false unless valid?
        save(repository: repository, requested_by: requested_by)
      end

      private

      def save(repository:, requested_by:)
        yield if block_given?
        event_receiver.trigger!(repository: repository, user: requested_by, entity: work, event_name: event_name)
        work
      end

      def default_event_receiver
        StateMachines
      end
    end
  end
end
