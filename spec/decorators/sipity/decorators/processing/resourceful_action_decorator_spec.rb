require 'spec_helper'

module Sipity
  module Decorators
    module Processing
      RSpec.describe ResourcefulActionDecorator do
        ENTITY_ID = '1234'
        let(:entity) { Models::Work.new(id: ENTITY_ID) }

        [
          { name: 'show', expected_path: "/works/#{ENTITY_ID}" },
          { name: 'new', expected_path: "/works/new" },
          { name: 'create', expected_path: "/works/new" },
          { name: 'edit', expected_path: "/works/#{ENTITY_ID}/edit" },
          { name: 'update', expected_path: "/works/#{ENTITY_ID}/edit" },
          { name: 'destroy', expected_path: "/works/#{ENTITY_ID}" }
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
