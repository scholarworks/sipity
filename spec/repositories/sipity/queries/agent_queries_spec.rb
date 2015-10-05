require 'rails_helper'
require 'sipity/queries/agent_queries'

module Sipity
  module Queries
    RSpec.describe AgentQueries, type: :isolated_repository_module do
      let(:repository) { QueryRepositoryInterface.new }

      context '#get_identifiable_agent_for' do
        let(:entity) { Models::Processing::Entity.new }
        let(:identifier_id) { 'bmV0aWQJamZyaWVzZW4=' }
        subject { test_repository.get_identifiable_agent_for(entity: entity, identifier_id: identifier_id, repository: repository) }

        context 'with a collaborator found for the entity' do
          let(:collaborator) { Models::Collaborator.new(identifier_id: identifier_id, netid: 'jfriesen') }
          before do
            allow(repository).to receive(:work_collaborators_for).with(
              work: entity, identifier_id: identifier_id
            ).and_return([collaborator])
          end
          it { should contractually_honor(Sipity::Interfaces::IdentifiableAgentInterface) }
        end

        context 'with a collaborator not found but a remote agent found' do
          let(:agent_not_it) { double(ids: []) }
          let(:agent_is_it) do
            double(name: 'Hello', email: 'hello@world.com', identifier_id: identifier_id, ids: [identifier_id])
          end
          before do
            allow(repository).to receive(:work_collaborators_for).with(work: entity, identifier_id: identifier_id).and_return([])
            allow(Queries::Complex::AgentsAssociatedWithEntity).to receive(:new).and_return([agent_not_it, agent_is_it])
          end
          it { should contractually_honor(Sipity::Interfaces::IdentifiableAgentInterface) }
        end

        context 'without collaborator or remote agent' do
          before do
            allow(repository).to receive(:work_collaborators_for).with(work: entity, identifier_id: identifier_id).and_return([])
            allow(Queries::Complex::AgentsAssociatedWithEntity).to receive(:new).and_return([])
          end
          it { should contractually_honor(Sipity::Interfaces::IdentifiableAgentInterface) }
        end
      end
    end
  end
end
