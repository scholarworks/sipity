require 'spec_helper'

module Sipity
  module Services
    RSpec.describe RegisterActionTakenOnEntity do
      let(:entity) { Models::Processing::Entity.new(id: 1, strategy_id: strategy.id, strategy: strategy) }
      let(:strategy) { Models::Processing::Strategy.new(id: 2) }
      let(:action) { Models::Processing::StrategyAction.new(id: 3, strategy_id: strategy.id, name: 'wowza') }

      subject { described_class.new(entity: entity, action: action) }
      its(:strategy) { should eq entity.strategy }

      context '.call' do
        it 'will delegate do the unerlying #initialize then #call' do
          allow(described_class).to receive(:new).and_call_original
          described_class.call(entity: entity, action: action)
        end
      end

      context '#call' do
        context 'with an invalid action for the given strategy' do
          let(:action) { '__invalid__' }
          it 'will raise an exception if the action is not valid for the strategy' do
            expect { subject.call }.to raise_error Exceptions::ProcessingStrategyActionConversionError
          end
        end
        context 'with a valid action object for the given strategy' do
          it 'will increment the registry' do
            expect { subject.call }.to change { Models::Processing::EntityActionRegister.count }.by(1)
          end
        end

        context 'with a valid action name for the given strategy' do
          it 'will increment the registry' do
            action.save!
            subject = described_class.new(entity: entity, action: action.name)
            expect { subject.call }.to change { Models::Processing::EntityActionRegister.count }.by(1)
          end
        end

        context 'with an action not associated with the given strategy' do
          let(:action) { Models::Processing::StrategyAction.new(id: 3) }
          it 'will raise an exception' do
            expect { subject.call }.to raise_error Exceptions::ProcessingStrategyActionConversionError
          end
        end
      end
    end
  end
end
