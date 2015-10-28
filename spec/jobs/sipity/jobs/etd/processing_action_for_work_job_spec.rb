require 'spec_helper'
require 'sipity/jobs/etd/processing_action_for_work_job'

RSpec.describe Sipity::Jobs::Etd::ProcessingActionForWorkJob do
  let(:context_builder) { double('ContextBuilder', call: :a_context) }
  let(:runner) { double('Runner', call: true) }
  let(:parameters) do
    { work_id: 1, processing_action_name: 'submit_for_ingest', requested_by: 'someone', context_builder: context_builder, runner: runner }
  end

  subject { described_class.new(parameters) }

  its(:attributes) { should eq({}) }
  its(:default_context_builder) { should respond_to(:call) }
  its(:default_runner) { should respond_to(:call) }

  it 'should expose .call as a convenience method' do
    expect_any_instance_of(described_class).to receive(:call)
    described_class.call(parameters)
  end

  context '#call' do
    it 'will call the given runner with the context and parameters' do
      expect(runner).to receive(:call).with(
        :a_context,
        work_id: parameters.fetch(:work_id),
        processing_action_name: subject.send(:processing_action_name),
        attributes: subject.send(:attributes)
      )
      subject.call
    end
  end
end
