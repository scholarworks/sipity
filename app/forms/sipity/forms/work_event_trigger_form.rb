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
        # TODO: This is not the final form; I believe I need to build the proper
        # event object that has a clear API. Its not the same as the form, because
        # the form is responsible for validations. The event is responsible for
        # being triggered.
        @event_to_trigger = attributes.fetch(:event_to_trigger) { default_event_to_trigger }
      end

      attr_reader :work, :event_name
      attr_reader :event_to_trigger
      private :event_to_trigger

      validates :work, presence: true
      validates :event_name, presence: true

      def submit(repository:, requested_by:)
        return false unless valid?
        save(repository: repository, requested_by: requested_by)
      end

      private

      def save(repository:, requested_by:)
        yield if block_given?
        # TODO: This works, but is inelegant and very much hard-coded
        # I knew to use the EtdWorkflow because the work is an ETD
        # I knew to trigger the event via a symbol because that is how the state
        # machine operates. Encode those assumptions to clarify intent.
        event_to_trigger.call(repository: repository, requested_by: requested_by)
        work
      end

      def logged_event_name
        File.join(self.class.to_s.underscore.sub('sipity/forms/', ''), 'submit', event_name)
      end

      def default_event_to_trigger
        lambda do |options|
          user = options.fetch(:requested_by)
          repository = options.fetch(:repository)
          StateMachines::EtdWorkflow.new(entity: work, user: user, repository: repository).trigger!(event_name.to_sym)
        end
      end
    end
  end
end
