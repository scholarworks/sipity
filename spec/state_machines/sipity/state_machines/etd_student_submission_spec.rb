require 'spec_helper'

module Sipity
  module StateMachines
    RSpec.describe EtdStudentSubmission do
      let(:initial_processing_state) { 'new' }
      let(:entity) { double('ETD', processing_state: initial_processing_state) }
      let(:user) { double('User') }
      let(:repository) do
        double(
          'Repository',
          update_processing_state!: true, log_event!: true, submit_etd_student_submission_trigger!: true,
          grant_groups_permission_to_entity_for_acting_as!: true, send_notification_for_entity_trigger: true, submit_ingest_etd: true
        )
      end
      subject { described_class.new(entity: entity, user: user, repository: repository) }

      context 'with the default repository' do
        subject { described_class.new(entity: entity, user: user) }
        its(:repository) { should respond_to :log_event! }
        its(:repository) { should respond_to :update_processing_state! }
        its(:repository) { should respond_to :submit_etd_student_submission_trigger! }
        its(:repository) { should respond_to :grant_groups_permission_to_entity_for_acting_as! }
        its(:repository) { should respond_to :send_notification_for_entity_trigger }
        its(:repository) { should respond_to :submit_ingest_etd }
      end

      context '.authorized_acting_as_for_action' do
        let(:initial_processing_state) { 'unknown' }
        it 'will raise an exception if the processing_state is unknown' do
          expect { subject.authorized_acting_as_for_action(:update?) }.to raise_error(Exceptions::StatePolicyQuestionRoleMapError)
        end
        context 'for :new' do
          let(:initial_processing_state) { 'new' }
          it 'will allow :update? for [:creating_user, :advisor]' do
            expect(subject.authorized_acting_as_for_action(:update?)).to eq(['creating_user', 'advisor'])
          end
          it 'will allow :delete? for [:creating_user]' do
            expect(subject.authorized_acting_as_for_action(:delete?)).to eq(['creating_user'])
          end
          it 'will allow :show? for [:creating_user, :advisor]' do
            expect(subject.authorized_acting_as_for_action(:show?)).to eq(['creating_user', 'advisor'])
          end
          it 'will allow :submit_for_review? for [:creating_user]'do
            expect(subject.authorized_acting_as_for_action(:submit_for_review?)).to eq(['creating_user'])
          end
        end

        context 'for :under_review' do
          let(:initial_processing_state) { 'under_review' }
          it 'will allow :update? for [:etd_reviewer]' do
            expect(subject.authorized_acting_as_for_action(:update?)).to eq(['etd_reviewer'])
          end
          it 'will allow :delete? for []' do
            expect(subject.authorized_acting_as_for_action(:delete?)).to eq([])
          end
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]' do
            expect(subject.authorized_acting_as_for_action(:show?)).to eq(['creating_user', 'advisor', 'etd_reviewer'])
          end
          it 'will allow :request_revisions? for [:etd_reviewer]' do
            expect(subject.authorized_acting_as_for_action(:request_revisions?)).to eq(['etd_reviewer'])
          end
          it 'will allow :approve_for_ingest? for [:etd_reviewer]' do
            expect(subject.authorized_acting_as_for_action(:approve_for_ingest?)).to eq(['etd_reviewer'])
          end
        end

        context 'for :ready_for_ingest' do
          let(:initial_processing_state) { 'ready_for_ingest' }
          it 'will allow :update? for []' do
            expect(subject.authorized_acting_as_for_action(:update?)).to eq([])
          end
          it 'will allow :delete? for []' do
            expect(subject.authorized_acting_as_for_action(:delete?)).to eq([])
          end
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]' do
            expect(subject.authorized_acting_as_for_action(:show?)).to eq(['creating_user', 'advisor', 'etd_reviewer'])
          end
          it 'will allow :ingest? for []' do
            expect(subject.authorized_acting_as_for_action(:ingest?)).to eq([])
          end
        end

        context 'for :ingesting' do
          let(:initial_processing_state) { 'ingesting' }
          it 'will allow :update? for []' do
            expect(subject.authorized_acting_as_for_action(:update?)).to eq([])
          end
          it 'will allow :delete? for []' do
            expect(subject.authorized_acting_as_for_action(:delete?)).to eq([])
          end
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]' do
            expect(subject.authorized_acting_as_for_action(:show?)).to eq(['creating_user', 'advisor', 'etd_reviewer'])
          end
          it 'will allow :ingest? for []' do
            expect(subject.authorized_acting_as_for_action(:ingest_completed?)).to eq([])
          end
        end

        context 'for :ready_for_cataloging' do
          let(:initial_processing_state) { 'ready_for_cataloging' }
          it 'will allow :update? for []' do
            expect(subject.authorized_acting_as_for_action(:update?)).to eq([])
          end
          it 'will allow :delete? for []' do
            expect(subject.authorized_acting_as_for_action(:delete?)).to eq([])
          end
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer, :cataloger]' do
            expect(subject.authorized_acting_as_for_action(:show?)).to eq(['creating_user', 'advisor', 'etd_reviewer', 'cataloger'])
          end
          it 'will allow :ingest? for []' do
            expect(subject.authorized_acting_as_for_action(:finish_cataloging?)).to eq(['cataloger'])
          end
        end

        context 'for :cataloged' do
          let(:initial_processing_state) { 'cataloged' }
          it 'will allow :update? for []' do
            expect(subject.authorized_acting_as_for_action(:update?)).to eq([])
          end
          it 'will allow :delete? for []' do
            expect(subject.authorized_acting_as_for_action(:delete?)).to eq([])
          end
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer, :cataloger]' do
            expect(subject.authorized_acting_as_for_action(:show?)).to eq(['creating_user', 'advisor', 'etd_reviewer', 'cataloger'])
          end
          it 'will allow :ingest? for []' do
            expect(subject.authorized_acting_as_for_action(:mark_as_done?)).to eq([])
          end
        end

        context 'for :done' do
          let(:initial_processing_state) { 'done' }
          it 'will allow :update? for []' do
            expect(subject.authorized_acting_as_for_action(:update?)).to eq([])
          end
          it 'will allow :delete? for []' do
            expect(subject.authorized_acting_as_for_action(:delete?)).to eq([])
          end
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer, :cataloger]' do
            expect(subject.authorized_acting_as_for_action(:show?)).to eq(['creating_user', 'advisor', 'etd_reviewer', 'cataloger'])
          end
        end
      end

      context 'processing_state transitions when' do
        let(:entity) { Models::Work.new(processing_state: initial_processing_state, id: 1) }
        let(:user) { User.new(id: 2) }
        let(:options) { {} }
        subject { described_class.new(entity: entity, user: user, repository: repository) }
        before { subject.trigger!(event, options) }
        context ':submit_for_review is triggered' do
          let(:initial_processing_state) { 'new' }
          let(:event) { :submit_for_review }
          it 'will send an email notification to the grad school' do
            expect(repository).to have_received(:send_notification_for_entity_trigger).
              with(notification: "entity_ready_for_review", entity: entity, acting_as: 'etd_reviewer')
          end
          it 'will send an email confirmation to the student with a URL to that item' do
            expect(repository).to have_received(:send_notification_for_entity_trigger).
              with(notification: "confirmation_of_entity_submitted_for_review", entity: entity, acting_as: 'creating_user')
          end
          it 'will add permission entries for the etd reviewers for the given ETD' do
            expect(repository).to have_received(:grant_groups_permission_to_entity_for_acting_as!).
              with(entity: entity, acting_as: 'etd_reviewer')
          end
          it 'will record the event for auditing purposes' do
            expect(repository).to have_received(:log_event!).
              with(entity: entity, user: user, event_name: "etd_student_submission/#{event}")
          end
          it 'will update the ETDs processing_state to :under_review'  do
            expect(repository).to have_received(:update_processing_state!).
              with(entity: entity, from: initial_processing_state, to: "under_review")
          end
          it 'will NOT trigger another state change' do
            expect(repository).to_not have_received(:submit_etd_student_submission_trigger!)
          end
        end

        context ':request_revisions is triggered' do
          let(:initial_processing_state) { 'under_review' }
          let(:event) { :request_revisions }
          let(:options) { { comments: 'Hello World' } }
          subject { described_class.new(entity: entity, user: user, repository: repository) }
          it 'will send an email notification to the student with a URL to edit the item and reviewer provided comments' do
            expect(repository).to(
              have_received(:send_notification_for_entity_trigger).with(
                notification: "request_revisions_from_creator", entity: entity, acting_as: 'creating_user',
                comments: options.fetch(:comments)
              )
            )
          end
          it 'will record the event for auditing purposes'  do
            expect(repository).to have_received(:log_event!).
              with(entity: entity, user: user, event_name: "etd_student_submission/#{event}")
          end
          it 'will update the ETDs processing_state to :revisions_needed' do
            expect(repository).to have_received(:update_processing_state!).
              with(entity: entity, from: initial_processing_state, to: "under_review")
          end
          it 'will NOT trigger another state change' do
            expect(repository).to_not have_received(:submit_etd_student_submission_trigger!)
          end
        end

        context ':approve_for_ingest is triggered' do
          let(:initial_processing_state) { 'under_review' }
          let(:event) { :approve_for_ingest }
          it 'will record the event for auditing purposes' do
            expect(repository).to have_received(:log_event!).
              with(entity: entity, user: user, event_name: "etd_student_submission/#{event}")
          end
          it 'will update the ETDs processing_state to :ready_for_ingest' do
            expect(repository).to have_received(:update_processing_state!).
              with(entity: entity, from: initial_processing_state, to: "ready_for_ingest")
          end
          it 'will trigger :ingest event' do
            expect(repository).to have_received(:submit_etd_student_submission_trigger!).
              with(entity: entity, trigger: :ingest, user: user)
          end
        end

        context ':ingest is triggered' do
          let(:initial_processing_state) { 'ready_for_ingest' }
          let(:event) { :ingest }
          it 'will submit an ROF job to ingest the ETD; Only ETD reviewers will have rights to the ingesting object' do
            expect(repository).to have_received(:submit_ingest_etd).
              with(entity: entity)
          end
          it 'will record the event for auditing purposes' do
            expect(repository).to have_received(:log_event!).
              with(entity: entity, user: user, event_name: "etd_student_submission/#{event}")
          end
          it 'will update the ETDs processing_state to :ingest_completed' do
            expect(repository).to have_received(:update_processing_state!).
              with(entity: entity, from: initial_processing_state, to: "ingesting")
          end
          it 'will NOT trigger another state change' do
            expect(repository).to_not have_received(:submit_etd_student_submission_trigger!)
          end
        end

        context ':ingest_completed is triggered' do
          let(:initial_processing_state) { 'ingesting' }
          let(:event) { :ingest_completed }
          let(:options) { { additional_emails: 'hello@world.com' } }
          it 'will send an email notification to the student and grad school and any additional emails provided (i.e. ISSA)' do
            expect(repository).to(
              have_received(:send_notification_for_entity_trigger).with(
                notification: "confirmation_of_entity_ingested", entity: entity,
                acting_as: ['creating_user', 'advisor', 'etd_reviewer'], additional_emails: options.fetch(:additional_emails)
              )
            )
          end
          it 'will add permission entries for the catalog reviewers of the given ETD' do
            expect(repository).to have_received(:grant_groups_permission_to_entity_for_acting_as!).
              with(entity: entity, acting_as: 'cataloger')
          end
          it 'will send an email notification to the catalogers saying the ETD is ready for cataloging' do
            expect(repository).to have_received(:send_notification_for_entity_trigger).
              with(notification: "entity_ready_for_cataloging", entity: entity, acting_as: 'cataloger')
          end
          it 'will record the event for auditing purposes' do
            expect(repository).to have_received(:log_event!).
              with(entity: entity, user: user, event_name: "etd_student_submission/#{event}")
          end
          it 'will update the ETDs processing_state to :ready_for_cataloging' do
            expect(repository).to have_received(:update_processing_state!).
              with(entity: entity, from: initial_processing_state, to: "ready_for_cataloging")
          end
          it 'will NOT trigger another state change' do
            expect(repository).to_not have_received(:submit_etd_student_submission_trigger!)
          end
        end

        context ':finish_cataloging is triggered' do
          let(:initial_processing_state) { 'ready_for_cataloging' }
          let(:event) { :finish_cataloging }
          it 'will record the event for auditing purposes' do
            expect(repository).to have_received(:log_event!).
              with(entity: entity, user: user, event_name: "etd_student_submission/#{event}")
          end
          it 'will update the ETDs processing_state to :cataloged' do
            expect(repository).to have_received(:update_processing_state!).
              with(entity: entity, from: initial_processing_state, to: "cataloged")
          end
          it 'will trigger the :finish event' do
            expect(repository).to have_received(:submit_etd_student_submission_trigger!).
              with(entity: entity, trigger: :finish, user: user)
          end
        end

        context ':finish is triggered' do
          let(:initial_processing_state) { 'cataloged' }
          let(:event) { :finish }
          it 'will record the event for auditing purposes' do
            expect(repository).to have_received(:log_event!).
              with(entity: entity, user: user, event_name: "etd_student_submission/#{event}")
          end
          it 'will update the ETDs processing_state to :done' do
            expect(repository).to have_received(:update_processing_state!).
              with(entity: entity, from: initial_processing_state, to: "done")
          end
          it 'will NOT trigger another state change' do
            expect(repository).to_not have_received(:submit_etd_student_submission_trigger!)
          end
        end
      end
    end
  end
end
