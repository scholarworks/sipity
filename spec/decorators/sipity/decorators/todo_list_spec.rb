require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe TodoList do
      let(:entity) { double('Entity') }
      let(:item_builder) { ->(value) { value } }
      subject { described_class.new(entity: entity, item_builder: item_builder) }

      context '#add_to_item_set' do
        it 'will create a new named item_set' do
          expect { subject.add_to(item_set: 'required', item_name: 'describe') }.
            to change { subject.item_sets.count }.by(1)
        end

        it 'will append an item to an existing item_set' do
          subject.add_to(item_set: 'required', item_name: 'describe')
          expect { subject.add_to(item_set: 'required', item_name: 'attach' ) }.
            to_not change { subject.item_sets.count }
        end
      end
    end
  end
end
