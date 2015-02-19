module Sipity
  module Forms
    # Submit a request for a DOI for the given Work
    class RequestADoiForm < BaseForm
      self.policy_enforcer = Policies::Processing::WorkProcessingPolicy

      def initialize(attributes = {})
        self.work = attributes.fetch(:work)
        @publisher, @publication_date = attributes.values_at(:publisher, :publication_date)
        @enrichment_type = attributes.fetch(:enrichment_type, default_enrichment_type)
      end

      attr_accessor :publisher, :publication_date, :work
      attr_reader :enrichment_type
      private(:work=) # Adding parenthesis because Beautify ruby was going crazy

      delegate :title, to: :work

      validates :work, presence: true
      validates :publisher, presence: true
      validates :publication_date, presence: true

      delegate :to_processing_entity, to: :work

      def authors(decorator: Decorators::CollaboratorDecorator)
        Queries::CollaboratorQueries.work_collaborators_for(work: work, role: 'author').
          map { |obj| decorator.decorate(obj) }
      end

      private

      def default_enrichment_type
        'assign_a_doi'
      end
    end
  end
end
