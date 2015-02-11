require 'spec_helper'

module Sipity
  module Decorators
    module Actions
      RSpec.describe EnrichmentAction do
        let(:action) { double(name: 'collaborators') }
        let(:entity) { double('Entity', to_param: '1234') }

        context 'default behavior' do
          subject { described_class.new(action: action, entity: entity) }
          its(:view_context) { should be_present }
        end

        subject { described_class.new(action: action, entity: entity) }
        its(:availability_state) { should eq('available') }
        its(:available?) { should eq(true) }

        [
          { name: 'collaborators', expected_path: "/works/1234/collaborators" },
          { name: 'attach', expected_path: "/works/1234/attach" },
          { name: 'describe', expected_path: "/works/1234/describe" }
        ].each_with_index do |example, index|
          it "will have a path #{example[:expected_path].inspect} for action name #{example[:name].inspect} (Scenario ##{index})" do
            action = double(name: example.fetch(:name))
            subject = described_class.new(action: action, entity: entity)
            expect(subject.path).to eq(example.fetch(:expected_path))
          end
        end
      end
    end
  end
end
