require "rails_helper"

module Sipity
  RSpec.describe DataGenerators::WorkAreaGenerator do
    let(:validator) { double(call: true) }
    let(:path) { Rails.root.join('app/data_generators/sipity/data_generators/work_areas/etd_work_area.config.json') }
    subject { described_class.new(data: {}, validator: validator) }

    its(:default_validator) { is_expected.to respond_to(:call) }
    its(:default_schema) { is_expected.to respond_to(:call) }

    it 'exposes .call as a convenience method' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call(path: path)
    end

    it 'validates the data against the schema' do
      subject
      expect(validator).to have_received(:call).with(data: subject.send(:data), schema: subject.send(:schema))
    end

    it 'will create submission window' do
      allow_any_instance_of(DataGenerators::SubmissionWindowGenerator).to receive(:call) # I want validation but not execution
      allow_any_instance_of(DataGenerators::StrategyPermissionsGenerator).to receive(:call)
      allow_any_instance_of(DataGenerators::ProcessingActionsGenerator).to receive(:call)
      expect do
        expect do
          expect do
            described_class.generate_from_json_file(path: path)
          end.to change { Models::WorkArea.count }.by(1)
        end.to change { Models::Processing::Strategy.count }.by(1)
      end.to change { Models::Processing::StrategyUsage.count }.by(1)

      [:update_attribute, :update_attributes, :update_attributes!, :save, :save!, :update, :update!].each do |method_names|
        expect_any_instance_of(ActiveRecord::Base).to_not receive(method_names)
      end
      described_class.generate_from_json_file(path: path)
    end
  end
end
