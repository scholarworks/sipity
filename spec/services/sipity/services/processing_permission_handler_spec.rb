require 'spec_helper'
require 'sipity/services/processing_permission_handler'

module Sipity
  module Services
    RSpec.describe ProcessingPermissionHandler do
      let(:entity) { Models::Processing::Entity.new(id: 1, strategy_id: strategy.id, strategy: strategy) }
      let(:strategy) { Models::Processing::Strategy.new(id: 2) }
      let(:role) { Models::Role.new(id: 3) }
      let(:identifiable) { User.new(username: 'hworld') }
      let(:strategy_role) { Models::Processing::StrategyRole.new(strategy_id: strategy.id, role_id: role.id) }
      let(:strategy_responsibility) do
        Sipity::Models::Processing::StrategyResponsibility.new(
          identifier_id: PowerConverter.convert_to_identifier_id(identifiable), strategy_role_id: strategy_role.id
        )
      end

      subject { described_class.new(entity: entity, role: role, identifiable: identifiable) }
      its(:strategy) { should eq entity.strategy }

      context '.grant' do
        it 'will instantiate then grant via the instance' do
          expect_any_instance_of(described_class).to receive(:grant)
          described_class.grant(entity: entity, role: role, actor: identifiable)
        end
      end

      context '#grant' do
        let(:fake_relation) { double(first!: strategy_role) }
        before do
          allow(PowerConverter).to receive(:convert_to_identifier_id).with(identifiable).and_return('an identifier')
        end
        it 'will raise an exception if the role is not valid for the strategy' do
          expect { subject.grant }.to raise_error Exceptions::ValidProcessingStrategyRoleNotFoundError
        end
        it 'will create an entity specific entry if one does not exist for [strategy,role]' do
          strategy_role.save!
          expect { subject.grant }.to change { Models::Processing::EntitySpecificResponsibility.count }.by(1)
        end
        it 'will NOT create an entity specific entry if an entry exists for [strategy,role]' do
          strategy_role.save!
          strategy_responsibility.save!
          allow(Sipity::Models::Processing::StrategyResponsibility).to receive(:count).and_return(1)
          expect { subject.grant }.to_not change { Models::Processing::EntitySpecificResponsibility.count }
        end
      end
    end
  end
end
