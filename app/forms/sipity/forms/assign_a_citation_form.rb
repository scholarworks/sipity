module Sipity
  module Forms
    # Responsible for capturing and validating information for citation creation.
    class AssignACitationForm < BaseForm
      self.policy_enforcer = Policies::Processing::WorkProcessingPolicy

      def initialize(attributes = {})
        @work = attributes.fetch(:work)
        @type, @citation = attributes.values_at(:type, :citation)
        @repository = attributes.fetch(:repository) { default_repository }
      end
      attr_accessor :type, :citation
      attr_reader :work, :repository
      private :repository

      def enrichment_type
        'assign_a_citation'
      end

      validates :work, presence: true
      validates :citation, presence: true
      validates :type, presence: true

      delegate :to_processing_entity, to: :work

      def submit(requested_by:)
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

      def default_repository
        CommandRepository.new
      end

      def event_name
        File.join(self.class.to_s.demodulize.underscore, 'submit')
      end
    end
  end
end
