require 'spec_helper'

RSpec.describe Sipity::Queries::Complex::AgentsAssociatedWithEntity do
  let(:role_identifier_1) { double('Role/ID', identifier_id: '123') }
  let(:role_identifier_2) { double('Role/ID', identifier_id: '456') }
  let(:agent_1) { double('Agent', identifier_id: '123') }
  let(:agent_2) { double('Agent', identifier_id: '456') }
  let(:aggregate_1) { double(role_name: 'creating_user') }
  let(:aggregate_2) { double(role_name: 'etd_reviewer') }
  let(:role_and_identifier_ids_finder) { double('Finder', call: [role_identifier_1, role_identifier_2]) }
  let(:agents_finder) { double('AgentsFinder', call: [agent_1, agent_2]) }
  let(:aggregator) { double('Aggregator', call: [aggregate_1, aggregate_2]) }
  let(:entity) { Sipity::Models::Processing::Entity.new }

  subject do
    described_class.new(
      entity: entity, role_and_identifier_ids_finder: role_and_identifier_ids_finder, agents_finder: agents_finder, aggregator: aggregator
    )
  end
  its(:default_role_and_identifier_ids_finder) { should respond_to(:call) }
  its(:default_agents_finder) { should respond_to(:call) }
  its(:default_aggregator) { should respond_to(:call) }

  it { should be_a(Enumerable) }

  context '#role_names_with_emails_for' do
    it 'will return an Hash of objects that have emails' do
      with_email = double('WithEmail', email: 'Hello', role_name: 'creating_user')
      without_email = double('WithoutEmail', role_name: 'something')
      expect(subject).to receive(:each).and_yield(with_email).and_yield(without_email)
      expect(subject.role_names_with_emails).to eq('creating_user' => [with_email.email], 'something' => [])
    end
  end

  context '#each' do
    it 'will return an enumerator if no block is given' do
      expect(subject.each).to be_a(Enumerator)
    end

    it 'will allow you to limit on a given set of roles' do
      # Mixing both role and a role_name
      roles = [Sipity::Models::Role.new(name: 'creating_user'), 'etd_reviewer']
      aggregate_3 = double(role_name: 'h')
      expect(subject).to receive(:aggregated_data).and_return([aggregate_1, aggregate_2, aggregate_3])
      expect { |b| subject.each(roles: roles, &b) }.to yield_successive_args(aggregate_1, aggregate_2)
    end

    it 'will find all of the role/identifier_id pairs' do
      subject.each { |*| }
      expect(role_and_identifier_ids_finder).to have_received(:call).with(entity: entity)
    end

    it 'will request the agents for the given identifier_ids' do
      subject.each { |*| }
      expect(agents_finder).to have_received(:call).with(
        identifiers: [role_identifier_1.identifier_id, role_identifier_2.identifier_id]
      )
    end

    it 'will aggregate the agents for the given identifier_ids' do
      subject.each { |*| }
      expect(aggregator).to have_received(:call).with(
        role_and_identifier_ids: [role_identifier_1, role_identifier_2], agents: [agent_1, agent_2]
      )
    end

    it 'will yield the aggregate information' do
      expect { |b| subject.each(&b) }.to yield_successive_args(aggregate_1, aggregate_2)
    end
  end
end

RSpec.describe Sipity::Queries::Complex::AgentsAssociatedWithEntity::RoleIdentifierFinder do
  subject { described_class }
  let(:entity) { Sipity::Models::Processing::Entity.new(id: 1, strategy_id: 2) }
  let(:role_creating_user) { Sipity::Models::Role.create!(name: 'creating_user') }
  let(:role_etd_reviewer) { Sipity::Models::Role.create!(name: 'etd_reviewer') }
  let(:role_advisor) { Sipity::Models::Role.create!(name: 'advisor') }
  let(:strategy_role_creating_user) do
    Sipity::Models::Processing::StrategyRole.create!(role: role_creating_user, strategy_id: entity.strategy_id)
  end
  let(:strategy_role_etd_reviewer) do
    Sipity::Models::Processing::StrategyRole.create!(role: role_etd_reviewer, strategy_id: entity.strategy_id)
  end
  before do
    Sipity::Models::Processing::StrategyRole.create!(role: role_advisor, strategy_id: entity.strategy_id)
    Sipity::Models::Processing::EntitySpecificResponsibility.create!(
      actor_id: 1, identifier_id: 'abc', entity_id: entity.id, strategy_role: strategy_role_etd_reviewer
    )
    Sipity::Models::Processing::StrategyResponsibility.create!(
      actor_id: 2, identifier_id: 'def', strategy_role: strategy_role_creating_user
    )
  end

  context '.all_for' do
    it 'will return a well defined data structure' do
      results = subject.all_for(entity: entity)
      sorted_results = results.map(&:attributes).sort { |a, b| a.fetch('identifier_id') <=> b.fetch('identifier_id') }
      expect(sorted_results).to eq(
        [
          {
            "id" => 0, "role_id" => 2, "role_name" => "etd_reviewer", "identifier_id" => "abc", "entity_id" => "1",
            "permission_grant_level" => "entity_level"
          }, {
            "id" => 0, "role_id" => 3, "role_name" => "creating_user", "identifier_id" => "def", "entity_id" => "1",
            "permission_grant_level" => "strategy_level"
          }
        ]
      )
    end

    it 'will allow for specific roles' do
      results = subject.all_for(entity: entity, role: 'creating_user')
      sorted_results = results.map(&:attributes).sort { |a, b| a.fetch('identifier_id') <=> b.fetch('identifier_id') }
      expect(sorted_results).to eq(
        [
          {
            "id" => 0, "role_id" => 3, "role_name" => "creating_user", "identifier_id" => "def", "entity_id" => "1",
            "permission_grant_level" => "strategy_level"
          }
        ]
      )
    end

    it 'will allow fetch of attributes' do
      results = subject.all_for(entity: entity, role: 'creating_user')
      expect(results.first.as_json.fetch('role_name')).to eq('creating_user')
    end
  end
end

RSpec.describe Sipity::Queries::Complex::AgentsAssociatedWithEntity::Aggregator do
  let(:role_and_identifier_ids) do
    [{
      "id" => nil, "role_id" => 2, "role_name" => "etd_reviewer", "identifier_id" => "Z3JvdXAJR3JhZHVhdGUgU2Nob29sIEVURCBSZXZpZXdlcnM=",
      "entity_id" => 1, "permission_grant_level" => "strategy_level"
    }, {
      "id" => nil, "role_id" => 3, "role_name" => "creating_user", "identifier_id" => "bmV0aWQJamZyaWVzZW4=", "entity_id" => 1,
      "permission_grant_level" => "entity_level"
    }]
  end
  let(:identifiers) { role_and_identifier_ids.map { |h| h.fetch('identifier_id') } }
  let(:client_request_handler) { ->(*) { Rails.root.join('spec/fixtures/cogitate/group_with_agents.response.json').read } }
  let(:agents) do
    Cogitate::Client.with_custom_configuration(client_request_handler: client_request_handler) do
      @agents = Cogitate::Client.request_agents_without_group_membership(identifiers: identifiers)
    end
    @agents
  end
  subject { described_class.aggregate(role_and_identifier_ids: role_and_identifier_ids, agents: agents) }

  context '.aggregate' do
    it 'will aggregate the names' do
      expect(subject.map { |a| [a.role_name, a.name] }).to eq(
        [
          ["etd_reviewer", "shill2"], ["creating_user", "jfriesen"]
        ]
      )
    end
  end
end
