require 'spec_helper'

module Sipity
  module Services
    RSpec.describe ActionTakenOnEntity do
      let(:entity) { Models::Processing::Entity.new(id: 1, strategy_id: strategy.id, strategy: strategy) }
      let(:strategy) { Models::Processing::Strategy.new(id: 2) }
      let(:requested_by) { Models::Processing::Actor.new(id: 4) }
      let(:on_behalf_of) { Models::Processing::Actor.new(id: 5) }
      let(:action) { Models::Processing::StrategyAction.new(id: 3, strategy_id: strategy.id, name: 'wowza') }

      subject { described_class.new(entity: entity, requested_by: requested_by, action: action) }

      context 'on_behalf_of behavior' do
        it 'will default to the requested_by if none are given' do
          expect(subject.on_behalf_of_actor).to eq(requested_by)
        end
        it 'will allow use the provider if one is specified' do
          subject = described_class.new(entity: entity, requested_by: requested_by, action: action, on_behalf_of: on_behalf_of)
          expect(subject.on_behalf_of_actor).to eq(on_behalf_of)
        end
      end

      [
        :register,
        :unregister
      ].each do |method_name|
        context ".#{method_name}" do
          it "will delegate do the unerlying #initialize then ##{method_name}" do
            allow(described_class).to receive(:new).and_call_original
            expect_any_instance_of(described_class).to receive(method_name)
            described_class.send(method_name, entity: entity, requested_by: requested_by, action: action)
          end
        end
      end

      context '#register' do
        context 'with a valid action object for the given entity' do
          it 'will increment the registry' do
            expect { subject.register }.to change { Models::Processing::EntityActionRegister.count }.by(1)
          end
        end
      end

      context '#register' do
        context 'with a valid action object for the given entity' do
          it 'will attempt to destroy the entry' do
            expect { subject.unregister }.to_not change { Models::Processing::EntityActionRegister.count }
          end
        end
      end

      context '#register then #unregister' do
        context 'with a valid action object for the given entity' do
          it 'will increment then decrement' do
            expect { subject.register }.to change { Models::Processing::EntityActionRegister.count }.by(1)
            expect { subject.unregister }.to change { Models::Processing::EntityActionRegister.count }.by(-1)
          end
        end
      end
    end
  end
end
