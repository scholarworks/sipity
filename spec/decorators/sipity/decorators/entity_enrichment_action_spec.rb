require 'spec_helper'
module Sipity
  module Decorators
    RSpec.describe EntityEnrichmentAction do
      let(:entity) { Models::Work.new(id: 123) }
      let(:name) { 'describe' }
      subject { described_class.new(entity: entity, name: name) }
      before { allow(entity).to receive(:persisted?).and_return(true) }
      its(:entity) { should eq(entity) }
      its(:name) { should eq(name) }
      its(:path) { should eq("/works/#{entity.to_param}/#{name}") }
      its(:path_to_new) { should eq("/works/#{entity.to_param}/#{name}/new") }

      it 'will have a translated label based on the given name and entity' do
        expect(subject.label).to eq("translation missing: en.sipity/decorators/entitiy_enrichment_actions.#{name}.label")
      end

      it 'will have a :path' do
        expect(subject.path).to eq("/works/#{entity.to_param}/#{name}")
      end

      it 'will have a :path_to_new' do
        expect(subject.path_to_new).to eq("/works/#{entity.to_param}/#{name}/new")
      end
    end
  end
end
