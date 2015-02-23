require 'spec_helper'

module Sipity
  module Services
    RSpec.describe RegisterActionTakenOnEntity do
      let(:entity) { Models::Processing::Entity.new(id: 1, strategy_id: strategy.id, strategy: strategy) }
      let(:strategy) { Models::Processing::Strategy.new(id: 2) }
      let(:requested_by) { Models::Processing::Actor.new(id: 4) }
      let(:action) { Models::Processing::StrategyAction.new(id: 3, strategy_id: strategy.id, name: 'wowza') }

      subject { described_class.new(entity: entity, requested_by: requested_by, action: action) }

      context '.call' do
        it 'will delegate do the unerlying #initialize then #call' do
          allow(described_class).to receive(:new).and_call_original
          described_class.call(entity: entity, requested_by: requested_by, action: action)
        end
      end

      context '#call' do
        context 'with a valid action object for the given entity' do
          it 'will increment the registry' do
            expect { subject.call }.to change { Models::Processing::EntityActionRegister.count }.by(1)
          end
        end
      end
    end
  end
end
