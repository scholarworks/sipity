require 'spec_helper'

module Sipity
  module StateMachines
    RSpec.describe EtdStudentSubmission do
      let(:etd) { double('ETD') }
      subject { described_class.new(etd) }

      context 'state based permissions' do
        context 'for :new' do
          it 'will allow :update? for [:creating_user, :advisor]'
          it 'will allow :delete? for [:creating_user]'
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]'
        end

        context 'for :under_review' do
          it 'will allow :update? for [:etd_reviewer]'
          it 'will allow :delete? for []'
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]'
        end

        context 'for :revisions_needed' do
          it 'will allow :update? for [:etd_reviewer]'
          it 'will allow :delete? for []'
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]'
        end

        context 'for :ready_for_ingest' do
          it 'will allow :update? for []'
          it 'will allow :delete? for []'
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]'
        end

        context 'for :ingested' do
          it 'will allow :update? for []'
          it 'will allow :delete? for []'
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]'
        end

        context 'for :ready_for_cataloging' do
          it 'will allow :update? for []'
          it 'will allow :delete? for []'
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]'
        end

        context 'for :cataloged' do
          it 'will allow :update? for []'
          it 'will allow :delete? for []'
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]'
        end

        context 'for :done' do
          it 'will allow :update? for []'
          it 'will allow :delete? for []'
          it 'will allow :show? for [:creating_user, :advisor, :etd_reviewer]'
        end
      end

      context 'state transitions when' do
        context ':student_submits is triggered' do
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

        context ':grad_school_approves is triggered' do
          it 'will send an email notification to the student and grad school and any additional emails provided (i.e. ISSA)'
          it 'will record the event for auditing purposes'
          it 'will update the ETDs state to :ready_for_ingest'
          it 'will trigger :ingest event'
        end

        context ':ingest is triggered' do
          it 'will submit an ROF job to ingest the ETD; Only ETD reviewers will have rights to the ingested object'
          it 'will record the event for auditing purposes'
          it 'will update the ETDs state to :ingested'
          it 'will trigger :ingest_completed'
        end

        context ':ingest_completed is triggered' do
          it 'will send an email notification to the catalogers saying the ETD is ready for cataloging'
          it 'will record the event for auditing purposes'
          it 'will update the ETDs state to :ready_for_cataloging'
        end

        context ':cataloging_completed is triggered' do
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
