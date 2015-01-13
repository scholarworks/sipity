module Sipity
  module Forms
    # Responsible for creating a new work.
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
        @work_type = attributes[:work_type]
        @access_rights_answer = attributes.fetch(:access_rights_answer) { default_access_rights_answer }
      end

      attr_accessor :title
      attr_accessor :work_publication_strategy
      attr_accessor :publication_date
      attr_accessor :work_type
      attr_accessor :access_rights_answer

      validates :title, presence: true
      validates :work_publication_strategy, inclusion: { in: :possible_work_publication_strategies }, presence: true
      validates :work_type, inclusion: { in: :possible_work_types }, presence: true
      validates :access_rights_answer, inclusion: { in: :possible_access_right_answers }, presence: true
      validates(:publication_date, presence: { if: :publication_date_required? })

      def access_rights_answer_for_select
        possible_access_right_answers.map(&:to_sym)
      end

      def work_publication_strategies_for_select
        possible_work_publication_strategies.map { |elem| elem.first.to_sym }
      end

      def work_types_for_select
        possible_work_types.map { |elem| elem.first.to_sym }
      end

      private

      def possible_work_types
        Models::Sip.work_types
      end

      def possible_work_publication_strategies
        Models::Sip.work_publication_strategies
      end

      def possible_access_right_answers
        # TODO: This is a rather invasive question
        Models::TransientAnswer::ANSWERS.fetch(Models::TransientAnswer::ACCESS_RIGHTS_QUESTION)
      end

      def publication_date_required?
        work_publication_strategy == Models::Sip::ALREADY_PUBLISHED
      end

      def default_access_rights_answer
        Models::TransientAnswer::ACCESS_RIGHTS_PRIVATE
      end
    end
  end
end
