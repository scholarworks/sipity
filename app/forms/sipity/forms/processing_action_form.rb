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

      self.policy_enforcer = Policies::Processing::WorkProcessingPolicy

      def initialize(attributes = {})
        @work = attributes.fetch(:work)
      end

      attr_reader :work
      delegate :to_processing_entity, to: :work

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
