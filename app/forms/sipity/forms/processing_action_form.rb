module Sipity
  module Forms
    # The generalized work enrichment form. It is unlikely that you will be able
    # to use this directly.
    class ProcessingActionForm
      include ActiveModel::Validations
      extend ActiveModel::Translation
      class_attribute :policy_enforcer

      def to_key
        []
      end

      def to_param
        nil
      end

      def persisted?
        to_param.nil? ? false : true
      end

      def render(*)
      end

      self.policy_enforcer = Policies::Processing::WorkProcessingPolicy

      def initialize(attributes = {})
        @work = attributes.fetch(:work)
        @repository = attributes.fetch(:repository) { default_repository }
      end

      attr_reader :work, :repository
      delegate :to_processing_entity, :work_type, to: :work
      delegate :strategy_id, :strategy, to: :to_processing_entity
      alias_method :to_model, :work
      private :repository

      validates :work, presence: true

      def submit(requested_by:)
        return false unless valid?
        save(requested_by: requested_by)
      end

      def enrichment_type
        fail NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
      end

      attr_reader :registered_action
      alias_method :to_registered_action, :registered_action

      private

      def save(requested_by:)
        @registered_action = repository.register_action_taken_on_entity(work: work, enrichment_type: enrichment_type, requested_by: requested_by)
        repository.log_event!(entity: work, user: requested_by, event_name: event_name)
        yield if block_given?
        work
      end

      def event_name
        File.join(self.class.to_s.underscore.sub('sipity/forms/', ''), 'submit')
      end

      def default_repository
        CommandRepository.new
      end
    end
  end
end
