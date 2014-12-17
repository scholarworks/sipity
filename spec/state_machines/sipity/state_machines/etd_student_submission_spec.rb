require 'spec_helper'

module Sipity
  module StateMachines
    RSpec.describe EtdStudentSubmission do
      let(:initial_processing_state) { :new }
      let(:entity) { double('ETD', processing_state: initial_processing_state) }
      let(:user) { double('User') }
      let(:repository) do
        double('Repository', update_processing_state!: true, log_event!: true, submit_etd_student_submission_trigger!: true)
      end
      subject { described_class.new(entity: entity, user: user, repository: repository) }

      context 'with the default repository' do
        subject { described_class.new(entity: entity, user: user) }
        its(:repository) { should respond_to :log_event! }
        its(:repository) { should respond_to :update_processing_state! }
        its(:repository) { should respond_to :submit_etd_student_submission_trigger! }
      end

      context '.roles_for_policy_question' do
        let(:initial_processing_state) { :unknown }
        it 'will raise an exception if the processing_state is unknown' do
          expect { subject.roles_for_policy_question(:update?) }.to raise_error(Exceptions::StatePolicyQuestionRoleMapError)
        end
        context 'for :new' do
          let(:initial_processing_state) { :new }
          it 'will allow :update? for [:creating_user, :advisor]' do
            expect(subject.roles_for_policy_question(:update?)).to eq(['creating_user', 'advisor'])
          end
          it 'will allow :delete? for [:creating_user]' do
            expect(subject.roles_for_policy_question(:delete?)).to eq(['creating_user'])
          end
          it 'will allow :show? for [:creating_user, :advisor]' do
            expect(subject.roles_for_policy_question(:show?)).to eq(['creating_user', 'advisor'])
          end
          it 'will allow :submit_for_ingest? for [:creating_user]'do
            expect(subject.roles_for_policy_question(:submit_for_ingest?)).to eq(['creating_user'])
          end
        end

        context 'for :under_review' do
          let(:initial_processing_state) { :under_review }
          it 'will allow :update? for [:etd_reviewer]' do
            expect(subject.roles_for_policy_question(:update?)).to eq(['etd_reviewer'])
          end
          it 'will allow :delete? for []' do
            expect(subject.roles_for_policy_question(:delete?)).to eq([])
          end
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]' do
            expect(subject.roles_for_policy_question(:show?)).to eq(['creating_user', 'advisor', 'etd_reviewer'])
          end
          it 'will allow :request_revisions? for [:etd_reviewer]' do
            expect(subject.roles_for_policy_question(:request_revisions?)).to eq(['etd_reviewer'])
          end
          it 'will allow :approve_for_ingest? for [:etd_reviewer]' do
            expect(subject.roles_for_policy_question(:approve_for_ingest?)).to eq(['etd_reviewer'])
          end
        end

        context 'for :revisions_needed' do
          let(:initial_processing_state) { :revisions_needed }
          it 'will allow :update? for [:etd_reviewer]' do
            expect(subject.roles_for_policy_question(:update?)).to eq(['etd_reviewer'])
          end
          it 'will allow :delete? for []' do
            expect(subject.roles_for_policy_question(:delete?)).to eq([])
          end
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]' do
            expect(subject.roles_for_policy_question(:show?)).to eq(['creating_user', 'advisor', 'etd_reviewer'])
          end
          it 'will allow :request_revisions? for [:etd_reviewer]' do
            expect(subject.roles_for_policy_question(:request_revisions?)).to eq(['etd_reviewer'])
          end
          it 'will allow :approve_for_ingest? for [:etd_reviewer]' do
            expect(subject.roles_for_policy_question(:approve_for_ingest?)).to eq(['etd_reviewer'])
          end
        end

        context 'for :ready_for_ingest' do
          let(:initial_processing_state) { :ready_for_ingest }
          it 'will allow :update? for []' do
            expect(subject.roles_for_policy_question(:update?)).to eq([])
          end
          it 'will allow :delete? for []' do
            expect(subject.roles_for_policy_question(:delete?)).to eq([])
          end
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]' do
            expect(subject.roles_for_policy_question(:show?)).to eq(['creating_user', 'advisor', 'etd_reviewer'])
          end
          it 'will allow :ingest? for []' do
            expect(subject.roles_for_policy_question(:ingest?)).to eq([])
          end
        end

        context 'for :ingested' do
          let(:initial_processing_state) { :ingested }
          it 'will allow :update? for []' do
            expect(subject.roles_for_policy_question(:update?)).to eq([])
          end
          it 'will allow :delete? for []' do
            expect(subject.roles_for_policy_question(:delete?)).to eq([])
          end
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]' do
            expect(subject.roles_for_policy_question(:show?)).to eq(['creating_user', 'advisor', 'etd_reviewer'])
          end
          it 'will allow :ingest? for []' do
            expect(subject.roles_for_policy_question(:ingest_completed?)).to eq([])
          end
        end

        context 'for :ready_for_cataloging' do
          let(:initial_processing_state) { :ready_for_cataloging }
          it 'will allow :update? for []' do
            expect(subject.roles_for_policy_question(:update?)).to eq([])
          end
          it 'will allow :delete? for []' do
            expect(subject.roles_for_policy_question(:delete?)).to eq([])
          end
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer, :cataloger]' do
            expect(subject.roles_for_policy_question(:show?)).to eq(['creating_user', 'advisor', 'etd_reviewer', 'cataloger'])
          end
          it 'will allow :ingest? for []' do
            expect(subject.roles_for_policy_question(:finish_cataloging?)).to eq(['cataloger'])
          end
        end

        context 'for :cataloged' do
          let(:initial_processing_state) { :cataloged }
          it 'will allow :update? for []' do
            expect(subject.roles_for_policy_question(:update?)).to eq([])
          end
          it 'will allow :delete? for []' do
            expect(subject.roles_for_policy_question(:delete?)).to eq([])
          end
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer, :cataloger]' do
            expect(subject.roles_for_policy_question(:show?)).to eq(['creating_user', 'advisor', 'etd_reviewer', 'cataloger'])
          end
          it 'will allow :ingest? for []' do
            expect(subject.roles_for_policy_question(:mark_as_done?)).to eq([])
          end
        end

        context 'for :done' do
          let(:initial_processing_state) { :done }
          it 'will allow :update? for []' do
            expect(subject.roles_for_policy_question(:update?)).to eq([])
          end
          it 'will allow :delete? for []' do
            expect(subject.roles_for_policy_question(:delete?)).to eq([])
          end
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer, :cataloger]' do
            expect(subject.roles_for_policy_question(:show?)).to eq(['creating_user', 'advisor', 'etd_reviewer', 'cataloger'])
          end
        end
      end

      context 'processing_state transitions when' do
        let(:entity) { Models::Header.new(processing_state: initial_processing_state, id: 1) }
        let(:user) { User.new(id: 2) }
        subject { described_class.new(entity: entity, user: user, repository: repository) }
        before { subject.trigger!(event) }
        context ':submit_for_ingest is triggered' do
          let(:initial_processing_state) { :new }
          let(:event) { :submit_for_ingest }
          it 'will send an email notification to the grad school'
          it 'will send an email confirmation to the student with a URL to that item'
          it 'will add permission entries for the etd reviewers for the given ETD'
          it 'will record the event for auditing purposes' do
            expect(repository).to have_received(:log_event!).
              with(entity: entity, user: user, event_name: "etd_student_submission_#{event}")
          end
          it 'will update the ETDs processing_state to :under_review'  do
            expect(repository).to have_received(:update_processing_state!).
              with(entity: entity, from: initial_processing_state, to: :under_review)
          end
        end

        context ':request_revisions is triggered' do
          let(:initial_processing_state) { :under_review }
          let(:event) { :request_revisions }
          subject { described_class.new(entity: entity, user: user, repository: repository) }
          it 'will send an email notification to the student with a URL to edit the item and reviewer provided comments'
          it 'will record the event for auditing purposes'  do
            expect(repository).to have_received(:log_event!).
              with(entity: entity, user: user, event_name: "etd_student_submission_#{event}")
          end
          it 'will update the ETDs processing_state to :revisions_needed' do
            expect(repository).to have_received(:update_processing_state!).
              with(entity: entity, from: initial_processing_state, to: :revisions_needed)
          end
        end

        context ':approve_for_ingest is triggered' do
          let(:initial_processing_state) { :under_review }
          let(:event) { :approve_for_ingest }
          it 'will send an email notification to the student and grad school and any additional emails provided (i.e. ISSA)'
          it 'will record the event for auditing purposes' do
            expect(repository).to have_received(:log_event!).
              with(entity: entity, user: user, event_name: "etd_student_submission_#{event}")
          end
          it 'will update the ETDs processing_state to :ready_for_ingest' do
            expect(repository).to have_received(:update_processing_state!).
              with(entity: entity, from: initial_processing_state, to: :ready_for_ingest)
          end
          it 'will trigger :ingest event' do
            expect(repository).to have_received(:submit_etd_student_submission_trigger!).
              with(entity: entity, trigger: :ingest)
          end
        end

        context ':ingest is triggered' do
          let(:initial_processing_state) { :ready_for_ingest }
          let(:event) { :ingest }
          it 'will submit an ROF job to ingest the ETD; Only ETD reviewers will have rights to the ingested object'
          it 'will record the event for auditing purposes' do
            expect(repository).to have_received(:log_event!).
              with(entity: entity, user: user, event_name: "etd_student_submission_#{event}")
          end
          it 'will update the ETDs processing_state to :ingest_completed' do
            expect(repository).to have_received(:update_processing_state!).
              with(entity: entity, from: initial_processing_state, to: :ingested)
          end
          it 'will add permission entries for the catalog reviewers of the given ETD'
          it 'will trigger :ingest_completed' do
            expect(repository).to have_received(:submit_etd_student_submission_trigger!).
              with(entity: entity, trigger: :ingest_completed)
          end
        end

        context ':ingest_completed is triggered' do
          let(:initial_processing_state) { :ingested }
          let(:event) { :ingest_completed }
          it 'will send an email notification to the catalogers saying the ETD is ready for cataloging'
          it 'will record the event for auditing purposes' do
            expect(repository).to have_received(:log_event!).
              with(entity: entity, user: user, event_name: "etd_student_submission_#{event}")
          end
          it 'will update the ETDs processing_state to :ready_for_cataloging' do
            expect(repository).to have_received(:update_processing_state!).
              with(entity: entity, from: initial_processing_state, to: :ready_for_cataloging)
          end
        end

        context ':finish_cataloging is triggered' do
          let(:initial_processing_state) { :ready_for_cataloging }
          let(:event) { :finish_cataloging }
          it 'will record the event for auditing purposes' do
            expect(repository).to have_received(:log_event!).
              with(entity: entity, user: user, event_name: "etd_student_submission_#{event}")
          end
          it 'will update the ETDs processing_state to :cataloged' do
            expect(repository).to have_received(:update_processing_state!).
              with(entity: entity, from: initial_processing_state, to: :cataloged)
          end
          it 'will trigger the :finish event' do
            expect(repository).to have_received(:submit_etd_student_submission_trigger!).
              with(entity: entity, trigger: :finish)
          end
        end

        context ':finish is triggered' do
          let(:initial_processing_state) { :cataloged }
          let(:event) { :finish }
          it 'will record the event for auditing purposes' do
            expect(repository).to have_received(:log_event!).
              with(entity: entity, user: user, event_name: "etd_student_submission_#{event}")
          end

          it 'will update the ETDs processing_state to :done' do
            expect(repository).to have_received(:update_processing_state!).
              with(entity: entity, from: initial_processing_state, to: :done)
          end
        end
      end
    end
  end
end
