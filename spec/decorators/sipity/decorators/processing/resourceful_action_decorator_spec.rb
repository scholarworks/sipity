require 'spec_helper'

module Sipity
  module Decorators
    module Processing
      RSpec.describe ResourcefulActionDecorator do
        ENTITY_ID = '1234'
        let(:entity) { Models::Work.new(id: ENTITY_ID) }

        it 'will not initialize with an invalid action name' do
          action = double(name: 'bob')
          expect { described_class.new(action: action, entity: entity) }.to raise_error(Exceptions::UnprocessableResourcefulActionNameError)
        end

        [
          { name: 'show', expected_path: "/works/#{ENTITY_ID}", button_class: 'btn-primary' },
          { name: 'new', expected_path: "/works/new", button_class: 'btn-primary' },
          { name: 'create', expected_path: "/works/new", button_class: 'btn-primary' },
          { name: 'edit', expected_path: "/works/#{ENTITY_ID}/edit", button_class: 'btn-primary' },
          { name: 'update', expected_path: "/works/#{ENTITY_ID}/edit", button_class: 'btn-primary' },
          { name: 'destroy', expected_path: "/works/#{ENTITY_ID}", button_class: 'btn-danger' }
        ].each_with_index do |example, index|
          it "will have a path #{example[:expected_path].inspect} for action name #{example[:name].inspect} (Scenario ##{index})" do
            action = double(name: example.fetch(:name))
            subject = described_class.new(action: action, entity: entity)
            expect(subject.path).to eq(example.fetch(:expected_path))
          end

          it "will have a button_class #{example[:button_class].inspect} for action name #{example[:name].inspect} (Scenario ##{index})" do
            action = double(name: example.fetch(:name))
            subject = described_class.new(action: action, entity: entity)
            expect(subject.button_class).to eq(example.fetch(:button_class))
          end
        end
      end
    end
  end
end
