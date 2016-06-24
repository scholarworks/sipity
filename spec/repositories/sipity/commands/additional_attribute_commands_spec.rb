require "rails_helper"
require 'sipity/commands/additional_attribute_commands'

module Sipity
  module Commands
    RSpec.describe AdditionalAttributeCommands, type: :command_with_related_query do
      # TODO: These are horribly comingled with the queries.
      #   Need to tease those apart.
      # Because of enum enforcement I need real key names
      let(:key) { Models::AdditionalAttribute::CITATION_PREDICATE_NAME }
      let(:key_2) { Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME }
      let(:work) { Models::Work.new(id: '123') }

      subject { test_repository }

      it 'will create a key/value pair if the value does not exist' do
        expect { subject.update_work_attribute_values!(work: work, key: key, values: 'abc') }.
          to change { subject.work_attribute_values_for(work: work, key: key) }.from([]).to(['abc'])
      end

      it 'will not create blank nodes' do
        expect { subject.update_work_attribute_values!(work: work, key: key, values: '') }.
          to_not change { subject.work_attribute_values_for(work: work, key: key) }
      end

      it 'will not create nodes for script tags' do
        expect { subject.update_work_attribute_values!(work: work, key: key, values: '<script>L337</script>') }.
          to_not change { subject.work_attribute_values_for(work: work, key: key) }
      end

      it 'will destroy_work_attribute_values a key/value pair if the value exists but is not part of the update' do
        subject.create_work_attribute_values!(work: work, key: key, values: 'abc')
        subject.update_work_attribute_values!(work: work, key: key, values: 'new_value')
        expect(subject.work_attribute_values_for(work: work, key: key)).to eq(['new_value'])
      end

      it 'will leave untouched a key/value pair if the key/value exists' do
        subject.create_work_attribute_values!(work: work, key: key, values: ['abc', 'def'])
        subject.update_work_attribute_values!(work: work, key: key, values: ['new_value', 'def'])
        expect(subject.work_attribute_values_for(work: work, key: key)).to eq(['def', 'new_value'])
      end

      it 'will handle mixed key/value pairs' do
        subject.create_work_attribute_values!(work: work, key: key, values: ['abc', 'def'])
        subject.create_work_attribute_values!(work: work, key: key_2, values: ['abc', 'def'])
        subject.update_work_attribute_values!(work: work, key: key, values: ['new_value', 'def'])
        expect(subject.work_attribute_values_for(work: work, key: key)).to eq(['def', 'new_value'])
        expect(subject.work_attribute_values_for(work: work, key: key_2)).to eq(['abc', 'def'])

      end

      it 'will not destroy_work_attribute_values when no values are specified' do
        subject.create_work_attribute_values!(work: work, key: key, values: ['abc'])
        subject.destroy_work_attribute_values!(work: work, key: key, values: [])
        expect(subject.work_attribute_values_for(work: work, key: key)).to eq(['abc'])
      end
    end
  end
end
