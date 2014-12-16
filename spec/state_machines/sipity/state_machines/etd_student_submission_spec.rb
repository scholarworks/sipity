require 'spec_helper'

module Sipity
  module StateMachines
    RSpec.describe EtdStudentSubmission do
      let(:etd) { double('ETD', state: state) }
      subject { described_class.new(etd) }

      context '.roles_for_policy_question' do
        let(:state) { :unknown }
        it 'will raise an exception if the state is unknown' do
          expect { subject.roles_for_policy_question(:update?) }.to raise_error(Exceptions::StatePolicyQuestionRoleMapError)
        end
        context 'for :new' do
          let(:state) { :new }
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
          let(:state) { :under_review }
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
          let(:state) { :revisions_needed }
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
          let(:state) { :ready_for_ingest }
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
          let(:state) { :ingested }
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
          let(:state) { :ready_for_cataloging }
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
          let(:state) { :cataloged }
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
          let(:state) { :done }
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

      context 'state transitions when' do
        context ':submit_for_ingest is triggered' do
          it 'will send an email notification to the grad school'
          it 'will send an email confirmation to the student with a URL to that item'
          it 'will add permission entries for the etd reviewers for the given ETD'
          it 'will record the event for auditing purposes'
          it 'will update the ETDs state to :under_review'
        end

        context ':request_revisions is triggered' do
          it 'will send an email notification to the student with a URL to edit the item and reviewer provided comments'
          it 'will record the event for auditing purposes'
          it 'will update the ETDs state to :revisions_needed'
        end

        context ':approve_for_ingest is triggered' do
          it 'will send an email notification to the student and grad school and any additional emails provided (i.e. ISSA)'
          it 'will record the event for auditing purposes'
          it 'will update the ETDs state to :ready_for_ingest'
          it 'will trigger :ingest event'
        end

        context ':ingest is triggered' do
          it 'will submit an ROF job to ingest the ETD; Only ETD reviewers will have rights to the ingested object'
          it 'will record the event for auditing purposes'
          it 'will update the ETDs state to :ingested'
          it 'will add permission entries for the catalog reviewers of the given ETD'
          it 'will trigger :ingest_completed'
        end

        context ':ingest_completed is triggered' do
          it 'will send an email notification to the catalogers saying the ETD is ready for cataloging'
          it 'will record the event for auditing purposes'
          it 'will update the ETDs state to :ready_for_cataloging'
        end

        context ':finish_cataloging is triggered' do
          it 'will record the event for auditing purposes'
          it 'will update the ETDs state to :cataloged'
          it 'will trigger the :finish event'
        end

        context ':finish is triggered' do
          it 'will record the event for auditing purposes'
          it 'will update the ETDs state to :done'
        end
      end
    end
  end
end
