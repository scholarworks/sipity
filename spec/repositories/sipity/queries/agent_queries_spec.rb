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

      context '#scope_creating_users_for_entity' do
        it "will leverage Complex::AgentsAssociatedWithEntity" do
          entity = double("Entity")
          expect(Complex::AgentsAssociatedWithEntity).to receive(:enumerator_for).with(entity: entity, roles: Models::Role::CREATING_USER)
          test_repository.scope_creating_users_for_entity(entity: entity)
        end
      end

      context "#user_emails_for_entity_and_roles" do
        it 'will be an array of emails' do
          role = double('Role')
          entity = double('Entity')
          expect(Complex::AgentsAssociatedWithEntity).to receive(:emails_for).with(entity: entity, roles: role).and_return(['an@email.com'])
          expect(test_repository.user_emails_for_entity_and_roles(entity: entity, roles: role)).to eq(['an@email.com'])
        end
      end

      context "#get_role_names_with_email_addresses_for" do
        it 'will be an hash keyed by role name with values of emails' do
          entity = double('Entity')
          expect(Complex::AgentsAssociatedWithEntity).to receive(:role_names_with_emails_for).with(entity: entity)
          test_repository.get_role_names_with_email_addresses_for(entity: entity)
        end
      end
    end
  end
end
