require 'spec_helper'
require 'sipity/queries/additional_attribute_queries'

RSpec.describe Sipity::Queries::AdditionalAttributeQueries, type: :isolated_repository_module do
  let(:work) { Sipity::Models::Work.new(id: 1) }
  let(:another_work) { Sipity::Models::Work.new(id: 2) }
  context '#work_attribute_values_for' do
    subject { test_repository.work_attribute_values_for(work: work, key: 'alternate_title') }
    before do
      Sipity::Models::AdditionalAttribute.create!(work_id: work.id, key: 'alternate_title', value: 'Title is Chicken')
      Sipity::Models::AdditionalAttribute.create!(work_id: another_work.id, key: 'alternate_title', value: 'Title is Soup')
      Sipity::Models::AdditionalAttribute.create!(work_id: work.id, key: 'abstract', value: 'An Abstract')
      Sipity::Models::AdditionalAttribute.create!(work_id: work.id, key: 'alternate_title', value: 'Title is Egg')
    end

    it 'will limit search to the given work' do
      expect(test_repository.work_attribute_values_for(work: work, key: 'alternate_title')).to eq(['Title is Chicken', 'Title is Egg'])
    end

    it 'will limit based on cardinality' do
      expect(test_repository.work_attribute_values_for(work: work, key: 'alternate_title', cardinality: 1)).to eq('Title is Chicken')
      expect(test_repository.work_attribute_values_for(work: work, key: 'alternate_title', cardinality: 2)).
        to eq(['Title is Chicken', 'Title is Egg'])
    end
  end
end
