module Sipity
  module Forms
    # Responsible for capturing and validating information for citation creation.
    class AssignACitationForm < WorkEnrichmentForm
      self.policy_enforcer = Policies::Processing::WorkProcessingPolicy

      def initialize(attributes = {})
        super
        @type, @citation = attributes.values_at(:type, :citation)
      end
      attr_accessor :type, :citation

      validates :citation, presence: true
      validates :type, presence: true

      private

      def save(requested_by:)
        super do |_f|
          repository.update_work_attribute_values!(
            work: work, key: Models::AdditionalAttribute::CITATION_PREDICATE_NAME, values: citation
          )
          repository.update_work_attribute_values!(
            work: work, key: Models::AdditionalAttribute::CITATION_TYPE_PREDICATE_NAME, values: type
          )
        end
      end

      def default_repository
        CommandRepository.new
      end
    end
  end
end
