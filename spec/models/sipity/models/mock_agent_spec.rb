require 'spec_helper'
require 'sipity/models/mock_agent'

RSpec.describe Sipity::Models::MockAgent do
  subject { described_class.new }
  its(:available_primary_strategies) { should be_a(Array) }
  its(:available_strategies) { should be_a(Array) }

  it { should validate_presence_of :email }
  it { should validate_presence_of :identifying_value }
  it { should validate_presence_of :strategy }
  it { should validate_inclusion_of(:strategy).in_array(described_class::AVAILABLE_PRIMARY_STRATEGIES) }

  context 'with NOT valid data' do
    before { expect(subject).to receive(:valid?).and_return(false) }
    its(:to_cogitate_data) { should eq({}) }
  end

  context 'with valid data' do
    subject do
      described_class.new(
        attributes: {
          email: 'hworld@nd.edu', identifying_value: 'hworld', strategy: 'NetID',
          verified_identifiers: { strategy: 'Group', identifying_value: 'Men with Hats' }
        }
      )
    end
    its(:to_cogitate_data) do
      should eq(
        "type" => "agents", "id" => "bmV0aWQJaHdvcmxk", "links" => { "self" => "http://localhost:3000/api/agents/bmV0aWQJaHdvcmxk" },
        "attributes" => { "strategy" => "netid", "identifying_value" => "hworld", "emails" => ["hworld@nd.edu"] },
        "relationships" => {
          "identifiers" => [],
          "verified_identifiers" => [{ "type" => "identifiers", "id" => "Z3JvdXAJTWVuIHdpdGggSGF0cw==" }]
        }, "included" => [
          {
            "type" => "identifiers", "id" => "Z3JvdXAJTWVuIHdpdGggSGF0cw==",
            "attributes" => { "identifying_value" => "Men with Hats", "strategy" => "group" }
          }
        ]
      )
    end
  end
end
