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
        self.repository = attributes.fetch(:repository) { default_repository }
      end

      attr_reader :title, :work_publication_strategy, :publication_date, :work_type, :access_rights_answer
      attr_accessor :repository
      private(:repository, :repository=)

      validates :title, presence: true
      validates :work_publication_strategy, presence: true, inclusion: { in: :possible_work_publication_strategies }
      validates :work_type, presence: true, inclusion: { in: :possible_work_types }
      validates :access_rights_answer, presence: true, inclusion: { in: :possible_access_right_answers }

      def access_rights_answer_for_select
        possible_access_right_answers.map(&:to_sym)
      end

      def work_publication_strategies_for_select
        possible_work_publication_strategies.map { |elem| elem.first.to_sym }
      end

      def work_types_for_select
        possible_work_types.map { |elem| elem.first.to_sym }
      end

      def submit(requested_by:)
        return false unless valid?
        create_the_work do |work|
          # I believe this form has too much knowledge of what is going on;
          # Consider pushing some of the behavior down into the repository.
          repository.handle_transient_access_rights_answer(entity: work, answer: access_rights_answer)
          repository.update_work_publication_date!(work: work, publication_date: publication_date)
          repository.grant_creating_user_permission_for!(entity: work, user: requested_by)
          repository.send_notification_for_entity_trigger(
            notification: "confirmation_of_entity_created", entity: work, acting_as: 'creating_user'
          )
          repository.log_event!(entity: work, user: requested_by, event_name: event_name)
        end
      end

      private

      def create_the_work
        work = repository.create_work!(title: title, work_publication_strategy: work_publication_strategy, work_type: work_type)
        yield(work)
        work
      end

      def possible_work_types
        Models::Work.work_types
      end

      def possible_work_publication_strategies
        Models::Work.work_publication_strategies
      end

      def possible_access_right_answers
        Models::TransientAnswer.access_rights_questions
      end

      def default_access_rights_answer
        Models::TransientAnswer::ACCESS_RIGHTS_PRIVATE
      end

      def event_name
        File.join(self.class.to_s.demodulize.underscore, 'submit')
      end

      def default_repository
        CommandRepository.new
      end
    end
  end
end
