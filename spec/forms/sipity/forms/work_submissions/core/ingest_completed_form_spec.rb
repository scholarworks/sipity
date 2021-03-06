require "rails_helper"
require 'sipity/forms/work_submissions/core/ingest_completed_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        RSpec.describe IngestCompletedForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:processing_action) { Models::Processing::StrategyAction.new(name: 'ingest_completed') }
          let(:attributes) { { job_state: described_class::JOB_STATE_SUCCESS } }
          let(:keywords) { { work: work, repository: repository, requested_by: user, attributes: attributes } }
          let(:user) { double('User') }
          subject { described_class.new(keywords) }

          its(:policy_enforcer) { is_expected.to eq Policies::WorkPolicy }
          its(:processing_action_name) { is_expected.to eq('ingest_completed') }

          it { is_expected.to respond_to :job_state }

          it { is_expected.to respond_to :work }
          it { is_expected.to delegate_method(:submit).to(:processing_action_form) }

          include Shoulda::Matchers::ActiveModel
          it { is_expected.to validate_inclusion_of(:job_state).in_array([described_class::JOB_STATE_SUCCESS]) }

          context 'with "error" for job_state' do
            let(:attributes) { { job_state: described_class::JOB_STATE_ERROR } }
            before do
              allow(subject).to receive(:valid?).and_return(false)
            end
            it 'will notify Airbrake' do
              expect(subject).to_not receive(:create_a_redirect)
              subject.submit
            end
            it 'will not submit' do
              expect(Airbrake).to receive(:notify_or_ignore).and_call_original
              subject.submit
            end
            its(:submit) { is_expected.to eq(false) }
          end

          context 'with invalid data' do
            before { expect(subject).to receive(:valid?).and_return(false) }
            its(:submit) { is_expected.to eq(false) }
          end

          context 'with valid data' do
            before do
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
            end
            it 'register the redirect for the ingested work' do
              expect(repository).to receive(:create_redirect_for).with(work: work, url: kind_of(String))
              subject.submit
            end
          end
        end
      end
    end
  end
end
