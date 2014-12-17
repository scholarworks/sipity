module Sipity
  module StateMachines
    # Responsible for overseeing the life cycle of the ETD Submisssion process.
    #
    # REVIEW: How is this different from crafting a handful of runners? Perhaps
    #   These should be codified as runners? Is there a symmetry of moving these
    #   to runners? Is symmetry worth pursuing?
    class EtdStudentSubmission
      # TODO: Extract policy questions into separate class; There is a
      # relationship, but is this necessary.
      #
      # { state => { policy_question => roles } }
      STATE_POLICY_QUESTION_ROLE_MAP =
      {
        new: {
          update?: ['creating_user', 'advisor'], show?: ['creating_user', 'advisor'],
          delete?: ['creating_user'], submit_for_review?: ['creating_user']
        },
        under_review: {
          update?: ['etd_reviewer'], show?: ['creating_user', 'advisor', 'etd_reviewer'],
          request_revisions?: ['etd_reviewer'], approve_for_ingest?: ['etd_reviewer']
        },
        ready_for_ingest: { show?: ['creating_user', 'advisor', 'etd_reviewer'] },
        ingested: { show?: ['creating_user', 'advisor', 'etd_reviewer'] },
        ready_for_cataloging: { show?: ['creating_user', 'advisor', 'etd_reviewer', 'cataloger'], finish_cataloging?: ['cataloger'] },
        cataloged: { show?: ['creating_user', 'advisor', 'etd_reviewer', 'cataloger'] },
        done: { show?: ['creating_user', 'advisor', 'etd_reviewer', 'cataloger'] }
      }.freeze

      def initialize(entity:, user:, repository: nil)
        @entity, @user = entity, user
        @repository = repository || default_repository
        # @TODO - Catch unexpected states.
        @state_machine = build_state_machine
      end
      attr_reader :entity, :state_machine, :user, :repository
      private :entity, :state_machine, :user, :repository

      def roles_for_policy_question(policy_question)
        # @TODO - Catch invalid state look up
        STATE_POLICY_QUESTION_ROLE_MAP.fetch(entity.processing_state).fetch(policy_question, [])
      rescue KeyError
        raise Exceptions::StatePolicyQuestionRoleMapError, state: entity.processing_state, context: self
      end

      def trigger!(event)
        state_machine.trigger!(event)
        after_successful_trigger!(event)
      end

      private

      def after_successful_trigger!(_event)
      end

      def build_state_machine
        state_machine = MicroMachine.new(entity.processing_state)
        build_state_machine_triggers(state_machine)
        build_state_machine_callbacks(state_machine)
        state_machine
      end

      def build_state_machine_triggers(state_machine)
        state_machine.when(:submit_for_review, new: :under_review)
        state_machine.when(:request_revisions, under_review: :under_review)
        state_machine.when(:approve_for_ingest, under_review: :ready_for_ingest)
        state_machine.when(:ingest, ready_for_ingest: :ingested)
        state_machine.when(:ingest_completed, ingested: :ready_for_cataloging)
        state_machine.when(:finish_cataloging, ready_for_cataloging: :cataloged)
        state_machine.when(:finish, cataloged: :done)
      end

      def build_state_machine_callbacks(state_machine)
        state_machine.on(:any) do |event_name|
          # REVIEW: Should I update the current entity instance's processing_state?
          repository.update_processing_state!(entity: entity, from: entity.processing_state, to: state_machine.state)
          repository.log_event!(entity: entity, user: user, event_name: convert_to_logged_name(event_name))
        end
        # TODO: MAGIC STRING ----------------------------------------------------------------------------------V
        state_machine.on(:under_review) { repository.assign_group_roles_to_entity(entity: entity, roles: 'etd_reviewer') }
        # TODO: MAGIC STRING -----------------------------------------------------------------------------------------V
        state_machine.on(:ready_for_cataloging) { repository.assign_group_roles_to_entity(entity: entity, roles: 'cataloger') }
        state_machine.on(:ready_for_ingest) { repository.submit_etd_student_submission_trigger!(entity: entity, trigger: :ingest) }
        state_machine.on(:ingested) { repository.submit_etd_student_submission_trigger!(entity: entity, trigger: :ingest_completed) }
        state_machine.on(:cataloged) { repository.submit_etd_student_submission_trigger!(entity: entity, trigger: :finish) }
      end

      # REVIEW: Will this be the convention? In other locations I'm using the
      # Runner.
      def convert_to_logged_name(event_name)
        "#{self.class.to_s.demodulize.underscore}/#{event_name}"
      end

      # REVIEW: Given that I need a repository, should this be teased into a
      # runner.
      def default_repository
        Repository.new
      end
    end
  end
end
