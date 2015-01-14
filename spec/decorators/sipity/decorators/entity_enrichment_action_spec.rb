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
    end
  end
end
