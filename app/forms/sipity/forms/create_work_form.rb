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

      validates :title,
                presence: { message: I18n.t('sipity/forms.create_work_form.error_messages.title') }
      validates :work_publication_strategy,
                presence: { message: I18n.t('sipity/forms.create_work_form.error_messages.work_publication_strategy') },
                inclusion: { in: :possible_work_publication_strategies, message: I18n.t('sipity/forms.error_messages.inclusion') }
      validates :work_type,
                presence: { message: I18n.t('sipity/forms.create_work_form.error_messages.work_type') },
                inclusion: { in: :possible_work_types, message: I18n.t('sipity/forms.error_messages.inclusion') }
      validates :access_rights_answer,
                presence: { message: I18n.t('sipity/forms.create_work_form.error_messages.access_rights_answer') },
                inclusion: { in: :possible_access_right_answers, message: I18n.t('sipity/forms.error_messages.inclusion') }

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
          # This method shows an intimate knowledge of the data structure of
          # what goes into a work. It works for now, but is something to consider.
          work = repository.create_work!(title: title, work_publication_strategy: work_publication_strategy, work_type: work_type)
          repository.handle_transient_access_rights_answer(entity: work, answer: f.access_rights_answer)
          repository.update_work_publication_date!(work: work, publication_date: f.publication_date)
          repository.grant_creating_user_permission_for!(entity: work, user: requested_by)
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
        Models::TransientAnswer.access_rights_questions
      end

      def default_access_rights_answer
        Models::TransientAnswer::ACCESS_RIGHTS_PRIVATE
      end
    end
  end
end
