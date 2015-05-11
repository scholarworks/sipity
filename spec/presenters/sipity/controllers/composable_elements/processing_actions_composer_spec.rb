module Sipity
  module Controllers
    module ComposableElements
      RSpec.describe ProcessingActionsComposer do
        let(:user) { double }
        let(:entity) { double }
        let(:repository) { QueryRepositoryInterface.new }
        let(:resourceful_action) { double(resourceful_action?: true, enrichment_action?: false, state_advancing_action?: false) }
        let(:enrichment_action) { double(resourceful_action?: false, enrichment_action?: true, state_advancing_action?: false) }
        let(:state_advancing_action) { double(resourceful_action?: false, enrichment_action?: false, state_advancing_action?: true) }
        let(:processing_actions) { [resourceful_action, enrichment_action, state_advancing_action] }

        subject { described_class.new(user: user, entity: entity, repository: repository) }

        its(:default_repository) { should respond_to :scope_permitted_entity_strategy_actions_for_current_state }
        its(:default_repository) { should respond_to :scope_strategy_actions_that_are_prerequisites }

        it 'exposes resourceful_actions' do
          allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return(processing_actions)
          expect(subject.resourceful_actions).to eq([resourceful_action])
        end

        it 'exposes resourceful_actions?' do
          allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return([resourceful_action])
          expect(subject.resourceful_actions?).to be_truthy
        end

        it 'exposes state_advancing_actions' do
          allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return(processing_actions)
          expect(subject.state_advancing_actions).to eq([state_advancing_action])
        end

        it 'exposes state_advancing_actions?' do
          allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return([state_advancing_action])
          expect(subject.state_advancing_actions?).to be_truthy
        end

        it 'exposes enrichment_actions' do
          allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return(processing_actions)
          expect(subject.enrichment_actions).to eq([enrichment_action])
        end

        it 'exposes enrichment_actions?' do
          allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return([enrichment_action])
          expect(subject.enrichment_actions?).to be_truthy
        end

        context '#enrichment_action_set_for' do
          let(:required_action) { double(id: 1) }
          let(:optional_action) { double(id: 2) }
          before do
            allow(subject).to receive(:enrichment_actions).and_return([required_action, optional_action])
            allow(repository).to receive(:scope_strategy_actions_that_are_prerequisites).
              with(entity: entity, pluck: :id).and_return([required_action.id])
          end
          it 'will handled "required" actions' do
            expect(subject.enrichment_action_set_for(identifier: 'required').collection).to eq([required_action])
          end
          it 'will handled "optional" actions' do
            expect(subject.enrichment_action_set_for(identifier: 'optional').collection).to eq([optional_action])
          end
          it 'will raise an exception for unknown' do
            expect { subject.enrichment_action_set_for(identifier: 'enchiladas') }.to raise_error(NoMethodError)
          end
        end
      end
    end
  end
end
