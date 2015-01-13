module Sipity
  module Forms
    # Submit a request for a DOI for the given Sip
    class RequestADoiForm < BaseForm
      self.policy_enforcer = Policies::EnrichSipByFormSubmissionPolicy

      def initialize(attributes = {})
        self.work = attributes.fetch(:work)
        @publisher, @publication_date = attributes.values_at(:publisher, :publication_date)
      end

      attr_accessor :publisher, :publication_date, :work
      private(:work=) # Adding parenthesis because Beautify ruby was going crazy

      delegate :title, to: :work

      validates :work, presence: true
      validates :publisher, presence: true
      validates :publication_date, presence: true

      def authors(decorator: Decorators::CollaboratorDecorator)
        Queries::CollaboratorQueries.work_collaborators_for(work: work, role: 'author').
          map { |obj| decorator.decorate(obj) }
      end
    end
  end
end
