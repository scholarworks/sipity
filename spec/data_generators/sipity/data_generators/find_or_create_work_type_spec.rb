require 'rails_helper'

module Sipity
  module DataGenerators
    RSpec.describe FindOrCreateWorkType do
      let(:name) { 'doctoral_dissertation' }

      it 'will create the work type' do
        expect do
          expect do
            expect do
              expect do
                described_class.call(name: name)
              end.to change { Models::WorkType.count }.by(1)
            end.to change { Models::Processing::Strategy.count }.by(1)
          end.to change { Models::Processing::StrategyState.count }.by(1)
        end.to change { Models::Processing::StrategyUsage.count }.by(1)
      end

      it 'will yield the work type, processing strategy, and strategy state' do
        expect { |b| described_class.call(name: name, &b) }.
          to yield_with_args(Models::WorkType, Models::Processing::Strategy, Models::Processing::StrategyState)
        expect { |b| described_class.call(name: name, &b) }.
          to yield_with_args(be_persisted, be_persisted, be_persisted)
      end

      it 'can be called repeatedly without updating things' do
        described_class.call(name: name)
        [:update_attribute, :update_attributes, :update_attributes!, :save, :save!, :update, :update!].each do |method_names|
          expect_any_instance_of(ActiveRecord::Base).to_not receive(method_names)
        end
        described_class.call(name: name)
      end
    end
  end
end
