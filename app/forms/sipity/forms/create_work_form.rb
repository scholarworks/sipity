module Sipity
  module Forms
    # Responsible for creating a new work.
    # What goes into this is more complicated that the entity might allow.
    class CreateWorkForm < BaseForm
      self.policy_enforcer = Policies::WorkPolicy

      def self.model_name
        Models::Work.model_name
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

      def submit(repository:, requested_by:)
        super() do |f|
          # REVIEW: Should the create work behavior be extracted to a repository
          #   command?
          work = Models::Work.create!(title: f.title, work_publication_strategy: f.work_publication_strategy)
          repository.handle_transient_access_rights_answer(entity: work, answer: f.access_rights_answer)
          repository.update_work_publication_date!(work: work, publication_date: f.publication_date)
          repository.grant_creating_user_permission_for!(entity: work, user: requested_by)
          repository.create_work_todo_list_for_current_state(work: work, processing_state: work.processing_state)
          repository.log_event!(entity: work, user: requested_by, event_name: __method__)
          work
        end
      end

      private

      def possible_work_types
        Models::Work.work_types
      end

      def possible_work_publication_strategies
        Models::Work.work_publication_strategies
      end

      def possible_access_right_answers
        # TODO: This is a rather invasive question
        Models::TransientAnswer::ANSWERS.fetch(Models::TransientAnswer::ACCESS_RIGHTS_QUESTION)
      end

      def publication_date_required?
        work_publication_strategy == Models::Work::ALREADY_PUBLISHED
      end

      def default_access_rights_answer
        Models::TransientAnswer::ACCESS_RIGHTS_PRIVATE
      end
    end
  end
end
