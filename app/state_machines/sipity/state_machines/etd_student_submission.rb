module Sipity
  module StateMachines
    # Responsible for overseeing the life cycle of the ETD Submisssion process.
    class EtdStudentSubmission
      attr_reader :etd
      def initialize(etd)
        @etd = etd
        build_state_machine
      end

      private

      def build_state_machine
        state_machine = MicroMachine.new(:new)
        state_machine.when(:student_submits, new: :under_review)
        state_machine.when(:request_revisions, under_review: :revisions_needed, revisions_needed: :revisions_needed)
        state_machine.when(:grad_school_approves, under_review: :ready_for_ingest, revisions_needed: :ready_for_ingest)
        state_machine.when(:ingest_completed, ready_for_ingest: :ingested)
        state_machine.when(:cataloging_completed, ingested: :cataloged)
        state_machine.when(:finish, cataloged: :done)
        @state_machine = state_machine
      end
    end
  end
end
