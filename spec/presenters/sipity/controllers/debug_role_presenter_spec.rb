require "rails_helper"
require 'sipity/controllers/debug_role_presenter'

module Sipity
  module Controllers
    RSpec.describe DebugRolePresenter, type: :presenter do
      let(:role) { double(id: '456', to_processing_entity: processing_entity, name: 'A Role', repository: repository, model_name: 'H') }
      let(:processing_entity) do
        double(id: '123', strategy_name: 'Shoe', strategy_id: '456', strategy_state_name: 'Untied', strategy_state_id: '789')
      end
      let(:context) { PresenterHelper::Context.new }
      let(:repository) { QueryRepositoryInterface.new }
      subject do
        described_class.new(context, debug_role: role)
      end

      it { is_expected.to delegate_method(:name).to(:debug_role) }
      it { is_expected.to delegate_method(:repository).to(:debug_role) }
      it { is_expected.to delegate_method(:to_processing_entity).to(:debug_role) }
      it { is_expected.to delegate_method(:role_id).to(:debug_role).as(:id) }
      it { is_expected.to delegate_method(:role_model_name).to(:debug_role).as(:model_name) }

      it 'will guard the interface of the role' do
        expect { described_class.new(context, debug_role: double) }.to raise_error(Exceptions::InterfaceExpectationError)
      end

      context '#debug_actors' do
        let(:actor) { double }
        it 'will delegate to the repository' do
          expect(repository).to receive(:scope_actors_associated_with_entity_and_role).
            with(entity: processing_entity, role: role).and_call_original
          subject.debug_actors
        end

        it 'will be an enumerable' do
          allow(repository).to receive(:scope_actors_associated_with_entity_and_role).and_return(actor)
          expect(subject.debug_actors).to eq([actor])
        end
      end
    end
  end
end
