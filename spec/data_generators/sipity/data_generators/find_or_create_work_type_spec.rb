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

      it 'can be called multiple times without creating new ones' do
        described_class.call(name: name)
        expect do
          expect do
            expect do
              expect do
                described_class.call(name: name)
              end.to_not change { Models::WorkType.count }
            end.to_not change { Models::Processing::Strategy.count }
          end.to_not change { Models::Processing::StrategyState.count }
        end.to_not change { Models::Processing::StrategyUsage.count }
      end
    end
  end
end
