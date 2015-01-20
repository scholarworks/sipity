require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe TodoList do
      let(:entity) { double('Entity') }
      let(:item_builder) { ->(value) { value } }
      subject { described_class.new(entity: entity, item_builder: item_builder) }

      it 'will accept a block on initialize' do
        expect { |b| described_class.new(entity: entity, &b) }.to yield_with_args(described_class)
      end
      context '#add_to' do
        it 'will create a new named set' do
          expect { subject.add_to(set: 'required', name: 'describe') }.
            to change { subject.sets.count }.by(1)
        end

        it 'will append an item to an existing set' do
          subject.add_to(set: 'required', name: 'describe')
          expect { subject.add_to(set: 'required', name: 'attach') }.
            to_not change { subject.sets.count }
        end
      end
    end
  end
end
