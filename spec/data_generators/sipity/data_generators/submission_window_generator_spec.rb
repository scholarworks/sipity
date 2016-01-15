require 'spec_helper'

module Sipity
  RSpec.describe DataGenerators::SubmissionWindowGenerator do
    let(:work_area) { Models::WorkArea.new(id: 2, slug: 'etd', partial_suffix: 'etd') }
    let(:validator) { double(call: true) }
    let(:path) { Rails.root.join('app/data_generators/sipity/data_generators/submission_windows/etd_submission_windows.config.json') }
    subject { described_class.new(work_area: work_area, data: {}, validator: validator) }

    its(:default_validator) { should respond_to(:call) }
    its(:default_schema) { should respond_to(:call) }

    it 'exposes .call as a convenience method' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call(work_area: work_area, path: path)
    end

    it 'validates the data against the schema' do
      subject
      expect(validator).to have_received(:call).with(data: subject.send(:data), schema: subject.send(:schema))
    end

    it 'will create submission window' do
      allow_any_instance_of(DataGenerators::WorkTypeGenerator).to receive(:call) # I want validation but not execution of the work_types
      allow_any_instance_of(DataGenerators::StrategyPermissionsGenerator).to receive(:call)
      allow_any_instance_of(DataGenerators::ProcessingActionsGenerator).to receive(:call)
      expect do
        expect do
          expect do
            described_class.generate_from_json_file(work_area: work_area, path: path)
          end.to change { Models::SubmissionWindow.count }.by(1)
        end.to change { Models::Processing::Strategy.count }.by(1)
      end.to change { Models::Processing::StrategyUsage.count }.by(1)

      [:update_attribute, :update_attributes, :update_attributes!, :save, :save!, :update, :update!].each do |method_names|
        expect_any_instance_of(ActiveRecord::Base).to_not receive(method_names)
      end
      described_class.generate_from_json_file(work_area: work_area, path: path)
    end
  end
end
