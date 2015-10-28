require 'spec_helper'
require 'sipity/jobs/etd/bulk_ingest_job'
require 'sipity/models/work'

RSpec.describe Sipity::Jobs::Etd::BulkIngestJob do
  let(:work_area) { 'etd' }
  let(:repository) { Sipity::QueryRepositoryInterface.new }
  let(:work_ingester) { double('Work Ingester', call: true) }

  subject { described_class.new(work_area: work_area, repository: repository, work_ingester: work_ingester) }

  its(:default_initial_processing_state_name) { should eq('ready_for_ingest') }
  its(:default_work_area) { should eq('etd') }
  its(:default_work_ingester) { should respond_to(:call) }
  its(:default_requested_by) { should be_a(String) }
  its(:default_search_criteria_builder) { should respond_to(:call) }
  its(:default_processing_action_name) { should eq('submit_for_ingest') }
  its(:default_repository) { should respond_to(:find_works_via_search) }

  it 'exposes .call as a convenience method' do
    expect_any_instance_of(described_class).to receive(:call)
    described_class.call(work_area: work_area, repository: repository)
  end

  context '.call' do
    it 'will find all entities for the given work area in the ready for ingest state' do
      work = Sipity::Models::Work.new(id: 1)
      expect(repository).to receive(:find_works_via_search).and_return([work])
      subject.call
      expect(work_ingester).to have_received(:call).with(
        work_id: work.id, requested_by: subject.send(:requested_by), processing_action_name: subject.send(:processing_action_name)
      )
    end
  end
end
