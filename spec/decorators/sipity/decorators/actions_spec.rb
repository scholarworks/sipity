require 'spec_helper'
require 'sipity/decorators/actions'

module Sipity
  module Decorators
    RSpec.describe Actions do
      [
        { action_names: ['show'], current_action_name: 'show', expected_names: [] },
        { action_names: ['update'], current_action_name: 'show', expected_names: ['update'] },
        { action_names: ['update'], current_action_name: 'edit', expected_names: [] },
        { action_names: ['update', 'show'], current_action_name: 'new', expected_names: ['update', 'show'] },
        { action_names: ['update', 'edit', 'show'], current_action_name: 'edit', expected_names: ['show'] },
        { action_names: ['update', 'submit_for_review'], current_action_name: 'edit', expected_names: ['submit_for_review'] }
      ].each_with_index do |example, index|
        it "will build named actions action set for scenario ##{index}" do
          actual = described_class.action_names_without_current_action_and_analogies(example.slice(:action_names, :current_action_name))
          expect(actual).to eq(example.fetch(:expected_names))
        end
      end

      [
        { action_name: 'new', expected_builder: Actions::ResourcefulAction },
        { action_name: 'create', expected_builder: Actions::ResourcefulAction },
        { action_name: 'show', expected_builder: Actions::ResourcefulAction },
        { action_name: 'edit', expected_builder: Actions::ResourcefulAction },
        { action_name: 'update', expected_builder: Actions::ResourcefulAction },
        { action_name: 'destroy', expected_builder: Actions::ResourcefulAction },
        { action_name: 'anything_else', expected_builder: Actions::StateAdvancingAction },
        { action_name: nil, expected_builder: Actions::StateAdvancingAction }
      ].each_with_index do |example, index|
        context '#builder_for_action_name' do
          it "will return a #{example[:expected_builder]} for action #{example[:action_name]} (Scenario ##{index}" do
            expect(described_class.builder_for_action_name(example.fetch(:action_name))).
              to eq(example.fetch(:expected_builder))
          end
        end

        context '#build' do
          it "will instantiate a #{example[:expected_builder]} for action #{example[:action_name]} (Scenario ##{index}" do
            expect(described_class.build(name: example.fetch(:action_name), repository: double, view_context: double, entity: double)).
              to be_a(example.fetch(:expected_builder))
          end
        end
      end
    end
  end
end
