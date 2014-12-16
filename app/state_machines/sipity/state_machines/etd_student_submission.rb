module Sipity
  module StateMachines
    # Responsible for overseeing the life cycle of the ETD Submisssion process.
    class EtdStudentSubmission
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

      attr_reader :etd
      def initialize(etd)
        @etd = etd
        build_state_machine
      end

      def roles_for_policy_question(policy_question)
        # @TODO - Catch invalid state look up
        STATE_POLICY_QUESTION_ROLE_MAP.fetch(etd.state).fetch(policy_question, [])
      rescue KeyError
        raise Exceptions::StatePolicyQuestionRoleMapError, state: etd.state, context: self
      end

      private

      def build_state_machine
        state_machine = MicroMachine.new(etd.state)
        state_machine.when(:submit_for_ingest, new: :under_review)
        state_machine.when(:request_revisions, under_review: :revisions_needed, revisions_needed: :revisions_needed)
        state_machine.when(:approve_for_ingest, under_review: :ready_for_ingest, revisions_needed: :ready_for_ingest)
        state_machine.when(:ingest_completed, ready_for_ingest: :ingested)
        state_machine.when(:finish_cataloging, ingested: :cataloged)
        state_machine.when(:finish, cataloged: :done)
        @state_machine = state_machine
      end
    end
  end
end
