require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe ActionSet do
      let(:entity) { double('Entity') }
      let(:repository) { double('Query Repository', are_all_of_the_required_todo_items_done_for_work?: are_todo_items_done?) }
      let(:are_todo_items_done?) { true }

      context 'default configuration (and an event_name)' do
        subject { described_class.new(entity: entity, event_names: 'show') }
        its(:current_action) { should eq(described_class::UNKNOWN_CURRENT_ACTION) }
        its(:repository) { should be_a(QueryRepository) }
        its(:present?) { should be_truthy }
        its(:empty?) { should be_falsey }
        it { should respond_to :each }
        it { should be_a Enumerable }
      end

      [
        { event_names: ['show'], current_action: 'show', expected_names: [] },
        { event_names: ['update'], current_action: 'show', expected_names: ['update'] },
        { event_names: ['update'], current_action: 'edit', expected_names: [] },
        { event_names: ['update', 'show'], current_action: 'new', expected_names: ['update', 'show'] },
        { event_names: ['update', 'edit', 'show'], current_action: 'edit', expected_names: ['show'] },
        { event_names: ['update', 'submit_for_review'], current_action: 'edit', expected_names: ['submit_for_review'] }
      ].each_with_index do |example, index|
        it "will build named actions action set for scenario ##{index}" do
          subject = described_class.new(example.merge(entity: entity, repository: repository))
          expect(subject.actions.map(&:name)).to eq(example[:expected_names])
        end
      end

      [
        { event_name: 'submit_for_review', are_todo_items_done?: true, expected_availability_state: 'available' },
        { event_name: 'submit_for_review', are_todo_items_done?: false, expected_availability_state: 'unavailable' },
        { event_name: 'edit', are_todo_items_done?: false, expected_availability_state: 'available' },
        { event_name: 'edit', are_todo_items_done?: true, expected_availability_state: 'available' }
      ].each_with_index do |example, index|
        it "will build an action for with the expected state for scenario ##{index}" do
          allow(repository).to receive(:are_all_of_the_required_todo_items_done_for_work?).
            and_return(example.fetch(:are_todo_items_done?))
          subject = described_class.new(entity: entity, repository: repository, event_names: example.fetch(:event_name)).actions.first
          expect(subject.availability_state).to eq(example.fetch(:expected_availability_state))
          expect(subject.available?).to eq(example.fetch(:expected_availability_state) == 'available')
        end
      end
    end
  end
end
