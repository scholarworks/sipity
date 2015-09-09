require 'spec_helper'

RSpec.describe Sipity::Services::Queries::AgentsAssociatedWithEntity do
  let(:role_identifier_1) { double('Role/ID', identifier_id: '123') }
  let(:role_identifier_2) { double('Role/ID', identifier_id: '456') }
  let(:agent_1) { double('Agent', identifier_id: '123') }
  let(:agent_2) { double('Agent', identifier_id: '456') }
  let(:role_and_identifier_ids_finder) { double('Finder', call: [role_identifier_1, role_identifier_2]) }
  let(:agents_finder) { double('AgentsFinder', call: [agent_1, agent_2]) }
  let(:aggregator) { double('Aggregator', call: [:aggregate_1, :aggregate_2]) }
  let(:entity) { Sipity::Models::Processing::Entity.new }

  subject do
    described_class.new(
      entity: entity, role_and_identifier_ids_finder: role_and_identifier_ids_finder, agents_finder: agents_finder, aggregator: aggregator
    )
  end
  its(:default_role_and_identifier_ids_finder) { should respond_to(:call) }
  its(:default_agents_finder) { should respond_to(:call) }
  its(:default_aggregator) { should respond_to(:call) }

  context '#each' do
    it 'will find all of the role/identifier_id pairs' do
      subject.each { |*| }
      expect(role_and_identifier_ids_finder).to have_received(:call).with(entity: entity)
    end

    it 'will request the agents for the given identifier_ids' do
      subject.each { |*| }
      expect(agents_finder).to have_received(:call).with(identifier_ids: [role_identifier_1.identifier_id, role_identifier_2.identifier_id])
    end

    it 'will aggregate the agents for the given identifier_ids' do
      subject.each { |*| }
      expect(aggregator).to have_received(:call).with(
        role_and_identifier_ids: [role_identifier_1, role_identifier_2], agents: [agent_1, agent_2]
      )
    end

    it 'will yield the aggregate information' do
      expect { |b| subject.each(&b) }.to yield_successive_args(:aggregate_1, :aggregate_2)
    end
  end
end
