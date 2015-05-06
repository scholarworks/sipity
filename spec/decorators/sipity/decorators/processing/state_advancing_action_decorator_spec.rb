require 'spec_helper'

module Sipity
  module Decorators
    module Processing
      RSpec.describe StateAdvancingActionDecorator do
        let(:entity) { Models::Work.new(id: 1234) }
        let(:user) { double }
        let(:action) { Models::Processing::StrategyAction.new(name: 'hello') }
        let(:repository) { QueryRepositoryInterface.new }
        subject { described_class.new(action: action, entity: entity, user: user, repository: repository) }

        it "will have a path" do
          expect(subject.path).to match(%r{/#{entity.id}/trigger/#{action.name}$})
        end

        its(:default_repository) { should respond_to(:scope_strategy_actions_with_incomplete_prerequisites) }

        context '.availability_state' do
          it 'will be STATE_PREREQUISITES_NOT_MET if prerequisite actions are not met' do
            expect(repository).to receive(:scope_strategy_actions_with_incomplete_prerequisites).and_return([action])
            expect(subject.availability_state).to eq(described_class::STATE_PREREQUISITES_NOT_MET)
          end

          it 'will be STATE_AVAILABLE if prerequisite actions are not met' do
            expect(repository).to receive(:scope_strategy_actions_with_incomplete_prerequisites).and_return([double])
            expect(subject.availability_state).to eq(described_class::STATE_AVAILABLE)
          end
        end
      end
    end
  end
end
