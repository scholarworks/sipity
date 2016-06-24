require "rails_helper"
require 'sipity/controllers/state_advancing_action_presenter'
# Because RSpec's described_class is getting confused
require 'sipity/controllers/state_advancing_action_presenter'

module Sipity
  module Controllers
    RSpec.describe StateAdvancingActionPresenter, type: :presenter do
      let(:context) { PresenterHelper::Context.new(current_user: current_user) }
      let(:current_user) { double('Current User') }
      let(:state_advancing_action) { Models::Processing::StrategyAction.new(name: 'create_a_window', id: 1) }
      let(:entity) { Models::Work.new(id: '12ab') }
      let(:repository) { QueryRepositoryInterface.new }
      let(:state_advancing_action_set) do
        Parameters::ActionSetParameter.new(identifier: 'required', collection: [state_advancing_action], entity: entity)
      end
      subject do
        described_class.new(
          context,
          state_advancing_action: state_advancing_action,
          state_advancing_action_set: state_advancing_action_set,
          repository: repository
        )
      end

      let(:actions_with_unmet_prerequisites) { [] }
      before do
        allow(repository).to receive(:scope_strategy_actions_with_incomplete_prerequisites).
          with(entity: entity, pluck: :id).and_return(actions_with_unmet_prerequisites)
      end

      its(:default_repository) { is_expected.to respond_to(:scope_strategy_actions_with_incomplete_prerequisites) }

      its(:action_name) { is_expected.to eq(state_advancing_action.name) }
      its(:path) { is_expected.to be_a(String) }

      it 'will delegate #label to the TranslationAssistant' do
        expect(TranslationAssistant).to receive(:call)
        subject.label
      end

      context 'with all actions having met the prerequites' do
        let(:actions_with_unmet_prerequisites) { [] }
        its(:available?) { is_expected.to eq(true) }
        its(:availability_state) { is_expected.to eq(described_class::STATE_AVAILABLE) }
      end

      context 'with unmet prequisites' do
        let(:actions_with_unmet_prerequisites) { [state_advancing_action.id] }
        its(:available?) { is_expected.to eq(false) }
        its(:availability_state) { is_expected.to eq(described_class::STATE_PREREQUISITES_NOT_MET) }
      end
    end
  end
end
