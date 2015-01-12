module Sipity
  module Forms
    # Responsible for creating a new sip.
    # What goes into this is more complicated that the entity might allow.
    class CreateSipForm < BaseForm
      self.policy_enforcer = Policies::SipPolicy

      def self.model_name
        Models::Sip.model_name
      end

      def initialize(attributes = {})
        @title = attributes[:title]
        @work_publication_strategy = attributes[:work_publication_strategy]
        @publication_date = attributes[:publication_date]
      end

      attr_accessor :title
      attr_accessor :work_publication_strategy
      attr_accessor :publication_date

      validates :title, presence: true
      validates :work_publication_strategy, inclusion: { in: :possible_work_publication_strategies }, presence: true
      validates(:publication_date, presence: { if: :publication_date_required? })

      def possible_work_publication_strategies
        Models::Sip.work_publication_strategies
      end

      private

      def publication_date_required?
        work_publication_strategy == Models::Sip::ALREADY_PUBLISHED
      end
    end
  end
end
