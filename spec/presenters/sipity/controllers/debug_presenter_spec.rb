require "rails_helper"
require 'sipity/controllers/debug_presenter'

module Sipity
  module Controllers
    RSpec.describe DebugPresenter, type: :presenter do
      let(:view_object) { double(to_s: 'Title', to_processing_entity: processing_entity) }
      let(:processing_entity) do
        double(id: '123', strategy_name: 'Shoe', strategy_id: '456', strategy_state_name: 'Untied', strategy_state_id: '789')
      end
      let(:context) { PresenterHelper::Context.new }
      let(:repository) { QueryRepositoryInterface.new }
      subject do
        described_class.new(context, repository: repository, view_object: view_object)
      end

      its(:object_name) { is_expected.to eq(view_object.to_s) }
      its(:processing_entity_id) { is_expected.to eq(processing_entity.id) }
      its(:processing_entity_strategy_name) { is_expected.to eq(processing_entity.strategy_name) }
      its(:processing_entity_strategy_id) { is_expected.to eq(processing_entity.strategy_id) }
      its(:processing_entity_strategy_state_name) { is_expected.to eq(processing_entity.strategy_state_name) }
      its(:processing_entity_strategy_state_id) { is_expected.to eq(processing_entity.strategy_state_id) }

      its(:default_repository) { is_expected.to respond_to(:scope_roles_associated_with_the_given_entity) }

      context '#debug_roles' do
        let(:role) { double }
        it 'will leverage a query on the repository' do
          expect(repository).to receive(:scope_roles_associated_with_the_given_entity).with(entity: processing_entity).and_call_original
          subject.debug_roles
        end

        it 'will be an enumerable of roles' do
          allow(repository).to receive(:scope_roles_associated_with_the_given_entity).with(entity: processing_entity).and_return(role)
          debug_role = subject.debug_roles.first
          expect(debug_role).to eq(role)
        end

        it 'will decorate each element with a to_processing_entity attribute/method' do
          allow(repository).to receive(:scope_roles_associated_with_the_given_entity).with(entity: processing_entity).and_return(role)
          debug_role = subject.debug_roles.first
          expect(debug_role.to_processing_entity).to eq(processing_entity)
          expect(debug_role.repository).to eq(repository)
        end
      end
    end
  end
end
