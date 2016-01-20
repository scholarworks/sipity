require 'spec_helper'
require 'sipity/data_generators/strategy_permissions_generator'

module Sipity
  module DataGenerators
    RSpec.describe StrategyPermissionsGenerator do
      let(:strategy) { Models::Processing::Strategy.new(name: 'Hello') }
      let(:strategy_permissions_configuration) do
        [
          { group: ["All Registered Users", "Somebody Else"], role: "work_submitting" },
          { group: ["All Registered Users", "Taco Truck Drivers"], role: "etd_reviewing" }
        ]
      end

      it 'exposes .call as a convenience method' do
        expect_any_instance_of(described_class).to receive(:call)
        described_class.call(strategy: strategy, strategy_permissions_configuration: strategy_permissions_configuration)
      end

      subject { described_class.new(strategy: strategy, strategy_permissions_configuration: strategy_permissions_configuration) }
      it 'will create groups and assign permissions accordingly' do
        allow_any_instance_of(PermissionGenerator).to receive(:call)
        expect do
          subject.call
        end.to change { Models::Group.count }.by(3)

        # And it won't keep creating things
        [:update_attribute, :update_attributes, :update_attributes!, :save, :save!, :update, :update!].each do |method_names|
          expect_any_instance_of(ActiveRecord::Base).to_not receive(method_names)
        end
        subject.call
      end
    end
  end
end
