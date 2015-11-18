require 'spec_helper'
require 'sipity/forms/work_submissions/etd/ingest_completed_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe IngestCompletedForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          let(:keywords) { { work: work, repository: repository, requested_by: user, attributes: { job_state: 'success' } } }
          let(:user) { double('User') }
          subject { described_class.new(keywords) }

          its(:policy_enforcer) { should eq Policies::WorkPolicy }
          its(:processing_action_name) { should eq('ingest_completed') }

          it { should respond_to :job_state }

          it { should respond_to :work }
          it { should delegate_method(:submit).to(:processing_action_form) }

          include Shoulda::Matchers::ActiveModel
          it { should validate_inclusion_of(:job_state).in_array([described_class::JOB_STATE_SUCCESS]) }

          context 'with invalid data' do
            before { expect(subject).to receive(:valid?).and_return(false) }
            its(:submit) { should eq(false) }
          end

          context 'with valid data' do
            before do
              allow(subject.send(:processing_action_form)).to receive(:submit).and_return(work)
            end
            its(:submit) { should eq(work) }
          end
        end
      end
    end
  end
end
