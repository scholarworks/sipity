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
          let(:keywords) { { work: work, repository: repository, requested_by: user } }
          let(:user) { double('User') }
          subject { described_class.new(keywords) }

          its(:policy_enforcer) { should eq Policies::WorkPolicy }

          it { should respond_to :work }
          it { should delegate_method(:submit).to(:processing_action_form) }

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
