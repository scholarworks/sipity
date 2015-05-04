require 'spec_helper'

module Sipity
  module Controllers
    module WorkAreas
      RSpec.describe ShowPresenter do
        let(:context) { PresenterHelper::Context.new(view_object: view_object, current_user: current_user) }
        let(:current_user) { double('Current User') }
        let(:view_object) { Models::WorkArea.new(slug: 'the-slug') }
        let(:resourceful_action) { double(resourceful_action?: true, enrichment_action?: false, state_advancing_action?: false) }
        let(:enrichment_action) { double(resourceful_action?: false, enrichment_action?: true, state_advancing_action?: false) }
        let(:state_advancing_action) { double(resourceful_action?: false, enrichment_action?: false, state_advancing_action?: true) }
        let(:processing_actions) { [resourceful_action, enrichment_action, state_advancing_action] }
        let(:repository) { QueryRepositoryInterface.new }
        subject { described_class.new(context, view_object: view_object, repository: repository) }

        its(:default_repository) { should respond_to :scope_permitted_entity_strategy_actions_for_current_state }

        it 'exposes processing_state' do
          allow(view_object).to receive(:processing_state).and_return('Hello')
          expect(subject.processing_state).to eq('Hello')
        end

        it 'sets the view_object' do
          expect(subject.view_object).to eq(view_object)
        end

        it 'exposes resourceful_actions' do
          allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return(processing_actions)
          expect(subject.resourceful_actions).to eq([resourceful_action])
        end

        it 'exposes resourceful_actions?' do
          allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return(processing_actions)
          expect(subject.resourceful_actions?).to be_truthy
        end

        it 'exposes state_advancing_actions' do
          allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return(processing_actions)
          expect(subject.state_advancing_actions).to eq([state_advancing_action])
        end

        it 'exposes state_advancing_actions?' do
          allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return(processing_actions)
          expect(subject.state_advancing_actions?).to be_truthy
        end

        it 'exposes enrichment_actions' do
          allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return(processing_actions)
          expect(subject.enrichment_actions).to eq([enrichment_action])
        end

        it 'exposes enrichment_actions?' do
          allow(repository).to receive(:scope_permitted_entity_strategy_actions_for_current_state).and_return(processing_actions)
          expect(subject.enrichment_actions?).to be_truthy
        end
      end
    end
  end
end
