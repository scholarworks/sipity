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
          delete?: ['creating_user'], submit_for_ingest?: ['creating_user']
        },
        under_review: {
          update?: ['etd_reviewer'], show?: ['creating_user', 'advisor', 'etd_reviewer'],
          request_revisions?: ['etd_reviewer'], approve_for_ingest?: ['etd_reviewer']
        },
        revisions_needed: {
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
        @state_machine = build_state_machine
        # @TODO - Catch unexpected states.
        @repository = repository || default_repository
      end
      attr_reader :entity, :state_machine, :user, :repository
      private :entity, :state_machine, :user, :repository

      def roles_for_policy_question(policy_question)
        # @TODO - Catch invalid state look up
        STATE_POLICY_QUESTION_ROLE_MAP.fetch(entity.processing_state).fetch(policy_question, [])
      rescue KeyError
        raise Exceptions::StatePolicyQuestionRoleMapError, state: entity.processing_state, context: self
      end

      delegate :trigger!, to: :state_machine

      private

      def build_state_machine
        state_machine = MicroMachine.new(entity.processing_state)
        build_state_machine_triggers(state_machine)
        build_state_machine_callbacks(state_machine)
        state_machine
      end

      def build_state_machine_triggers(state_machine)
        state_machine.when(:submit_for_ingest, new: :under_review)
        state_machine.when(:request_revisions, under_review: :revisions_needed, revisions_needed: :revisions_needed)
        state_machine.when(:approve_for_ingest, under_review: :ready_for_ingest, revisions_needed: :ready_for_ingest)
        state_machine.when(:ingest, ready_for_ingest: :ingest_completed)
        state_machine.when(:ingest_completed, ingest_completed: :ready_for_cataloging)
        state_machine.when(:finish_cataloging, ready_for_cataloging: :cataloged)
        state_machine.when(:finish, cataloged: :done)
      end

      def build_state_machine_callbacks(state_machine)
        state_machine.on(:any) do |event_name|
          # REVIEW: Should I update the current entity instance's processing_state?
          repository.update_processing_state!(entity: entity, new_processing_state: state_machine.state)
          repository.log_event!(entity: entity, user: user, event_name: convert_to_logged_name(event_name))
        end
      end

      # REVIEW: Will this be the convention? In other locations I'm using the
      # Runner.
      def convert_to_logged_name(event_name)
        "#{self.class.to_s.demodulize.underscore}_#{event_name}"
      end

      # REVIEW: Given that I need a repository, should this be teased into a
      # runner.
      def default_repository
        Repository.new
      end
    end
  end
end
