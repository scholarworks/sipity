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
    end
  end
end
