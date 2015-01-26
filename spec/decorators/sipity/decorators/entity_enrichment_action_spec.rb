require 'spec_helper'
module Sipity
  module Decorators
    RSpec.describe EntityEnrichmentAction do
      let(:entity) { Models::Work.new(id: 123) }
      let(:name) { 'describe' }
      subject { described_class.new(entity: entity, name: name, state: 'incomplete') }
      before { allow(entity).to receive(:persisted?).and_return(true) }
      its(:entity) { should eq(entity) }
      its(:name) { should eq(name) }
      its(:state) { should be_a(String) }
      its(:path) { should eq("/works/#{entity.to_param}/#{name}") }

      it 'will have a translated label based on the given name and entity' do
        expect(subject.label).to eq("translation missing: en.sipity/decorators/entitiy_enrichment_actions.#{name}.label")
      end

    end
  end
end
