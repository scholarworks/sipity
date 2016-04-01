module Sipity
  module Controllers
    module ComposableElements
      RSpec.describe ProcessingActionsComposer do
        let(:user) { double }
        let(:entity) { double(processing_state: 'hello') }
        let(:repository) { QueryRepositoryInterface.new }
        let(:resourceful_action) { double(name: 'a', resourceful_action?: true, enrichment_action?: false, state_advancing_action?: false) }
        let(:enrichment_action) { double(name: 'b', resourceful_action?: false, enrichment_action?: true, state_advancing_action?: false) }
        let(:state_advancing_action) do
          double(name: 'c', resourceful_action?: false, enrichment_action?: false, state_advancing_action?: true)
        end
        let(:processing_actions) { [resourceful_action, enrichment_action, state_advancing_action] }

        subject { described_class.new(user: user, entity: entity, repository: repository) }

        its(:default_repository) { is_expected.to respond_to :scope_permitted_entity_strategy_actions_for_current_state }
        its(:default_repository) { is_expected.to respond_to :scope_strategy_actions_that_are_prerequisites }
        its(:default_repository) { is_expected.to respond_to :scope_strategy_actions_with_incomplete_prerequisites }
        its(:default_action_names_to_skip) { is_expected.to eq(['show']) }

        it 'will omit the skipped action names' do
          subject = described_class.new(
            user: user, entity: entity, repository: repository, action_names_to_skip: processing_actions.map(&:name)
          )
          allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return(processing_actions)
          expect(subject.send(:processing_actions)).to eq([])
        end

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

        context '#can_advance_processing_state?' do
          it 'will be true if the only actions with prerequisites are non-state_advancing_actions' do
            allow(repository).to receive(:scope_strategy_actions_with_incomplete_prerequisites).and_return([enrichment_action])
            allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return(processing_actions)

            # Because only an enrichment action has an incomplete prerequisite
            expect(subject.can_advance_processing_state?).to be_truthy
          end

          it 'will be false if there exists at least one state advancing action with incomplete prerequisites' do
            allow(repository).to receive(:scope_strategy_actions_with_incomplete_prerequisites).and_return([state_advancing_action])
            allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return(processing_actions)
            expect(subject.can_advance_processing_state?).to be_falsey
          end
        end

        context '#action_set_for' do
          let(:required_action) { double(id: 1) }
          let(:optional_action) { double(id: 2) }
          context 'enrichment_actions' do
            before do
              allow(subject).to receive(:enrichment_actions).and_return([required_action, optional_action])
              allow(repository).to receive(:scope_strategy_actions_that_are_prerequisites).
                with(entity: entity, pluck: :id).and_return([required_action.id])
            end
            it 'will handled "required" actions' do
              expect(subject.action_set_for(name: 'enrichment_actions', identifier: 'required').collection).to eq([required_action])
            end
            it 'will handled "optional" actions' do
              expect(subject.action_set_for(name: 'enrichment_actions', identifier: 'optional').collection).to eq([optional_action])
            end
            it 'will raise an exception for unknown' do
              expect { subject.action_set_for(name: 'enrichment_actions', identifier: 'enchiladas') }.to raise_error(NoMethodError)
            end
          end

          it 'will handle :state_advancing_actions' do
            expect(subject).to receive(:state_advancing_actions).and_return([optional_action])
            subject.action_set_for(name: 'state_advancing_actions')
          end

          it 'will handle :resourceful_actions' do
            expect(subject).to receive(:resourceful_actions).and_return([optional_action])
            subject.action_set_for(name: 'resourceful_actions')
          end
        end
      end
    end
  end
end
