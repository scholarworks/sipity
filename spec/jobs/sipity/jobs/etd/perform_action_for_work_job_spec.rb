require 'spec_helper'
require 'sipity/jobs/etd/perform_action_for_work_job'

RSpec.describe Sipity::Jobs::Etd::PerformActionForWorkJob do
  let(:context_builder) { double('ContextBuilder', call: :a_context) }
  let(:runner) { double('Runner', call: true) }
  let(:processing_action_handler) { double('ProcessingActionHandler', run_and_respond_with_processing_action: true) }
  let(:processing_action_handler_builder) { double(call: processing_action_handler) }
  let(:parameters) do
    {
      work_id: 1, processing_action_name: 'submit_for_ingest', requested_by: 'someone', context_builder: context_builder, runner: runner,
      processing_action_handler_builder: processing_action_handler_builder
    }
  end

  subject { described_class.new(parameters) }

  its(:attributes) { is_expected.to eq({}) }
  its(:default_context_builder) { is_expected.to respond_to(:call) }
  its(:default_runner) { is_expected.to respond_to(:call) }
  its(:default_processing_action_handler_builder) { is_expected.to respond_to(:call) }

  it 'should expose .call as a convenience method' do
    expect_any_instance_of(described_class).to receive(:call)
    described_class.call(parameters)
  end

  context '#call' do
    it 'will call the given runner with the context and parameters' do
      expect(processing_action_handler).to receive(:run_and_respond_with_processing_action).with(
        work_id: parameters.fetch(:work_id),
        attributes: subject.send(:attributes)
      )
      subject.call
    end
  end
end
