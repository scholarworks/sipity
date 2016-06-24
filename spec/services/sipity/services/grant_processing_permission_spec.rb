require 'rails_helper'
require 'sipity/services/grant_processing_permission'

module Sipity
  module Services
    RSpec.describe GrantProcessingPermission do
      let(:entity) { Models::Processing::Entity.new(id: 1, strategy_id: strategy.id, strategy: strategy) }
      let(:strategy) { Models::Processing::Strategy.new(id: 2) }
      let(:role) { Models::Role.new(id: 3) }
      let(:actor) { Models::Processing::Actor.new(id: 4) }
      let(:strategy_role) { Models::Processing::StrategyRole.new(strategy_id: strategy.id, role_id: role.id) }
      let(:strategy_responsibility) do
        Sipity::Models::Processing::StrategyResponsibility.new(actor_id: actor.id, strategy_role_id: strategy_role.id)
      end

      subject { described_class.new(entity: entity, role: role, actor: actor) }
      its(:strategy) { is_expected.to eq entity.strategy }

      context '.call' do
        it 'will instantiate then call the instance' do
          expect(described_class).to receive(:new).and_return(double(call: true))
          described_class.call(entity: entity, role: role, actor: actor)
        end
      end

      context '#call' do
        let(:fake_relation) { double(first!: strategy_role) }
        before do
        end
        it 'will raise an exception if the role is not valid for the strategy' do
          expect { subject.call }.to raise_error Exceptions::ValidProcessingStrategyRoleNotFoundError
        end
        it 'will create an entity specific entry if one does not exist for [strategy,role]' do
          strategy_role.save!
          expect { subject.call }.to change { Models::Processing::EntitySpecificResponsibility.count }.by(1)
        end
        it 'will NOT create an entity specific entry if an entry exists for [strategy,role]' do
          strategy_role.save!
          strategy_responsibility.save!
          allow(Sipity::Models::Processing::StrategyResponsibility).to receive(:count).and_return(1)
          expect { subject.call }.to_not change { Models::Processing::EntitySpecificResponsibility.count }
        end
      end
    end
  end
end
