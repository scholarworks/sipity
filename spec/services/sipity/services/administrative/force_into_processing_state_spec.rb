require 'spec_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/services/administrative/force_into_processing_state'

module Sipity
  RSpec.describe Services::Administrative::ForceIntoProcessingState do
    let(:strategy) { Models::Processing::Strategy.create!(name: 'avacado') }
    let!(:new_strategy_state) { Models::Processing::StrategyState.create!(strategy: strategy, name: 'bacon') }
    let(:repository) { CommandRepositoryInterface.new }
    let(:entity) do
      Models::Processing::Entity.create!(proxy_for_id: 1, proxy_for_type: Sipity::Models::Work, strategy: strategy, strategy_state_id: 100)
    end

    subject { described_class.new(entity: entity, state: 'bacon', repository: repository) }

    its(:default_repository) { is_expected.to respond_to :destroy_existing_registered_state_changing_actions_for }
    it 'exposes .call as a convenience method' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call(entity: entity, state: 'bacon', repository: repository)
    end

    context '#call' do
      it 'will change the state' do
        expect(repository).to receive(:destroy_existing_registered_state_changing_actions_for).and_call_original
        subject.call
        entity.reload
        expect(entity.strategy_state_id).to eq(new_strategy_state.id)
      end
    end
  end
end
