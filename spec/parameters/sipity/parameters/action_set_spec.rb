require 'spec_helper'

module Sipity
  module Parameters
    RSpec.describe ActionSet do
      let(:identifier) { double }
      let(:collection) { double(any?: true, present?: true) }
      let(:entity) { double }
      subject { described_class.new(identifier: identifier, collection: collection, entity: entity) }
      its(:identifier) { should eq identifier }
      its(:collection) { should eq [collection] }
      its(:entity) { should eq entity }
      its(:any?) { should eq collection.any? }
      its(:present?) { should eq collection.present? }
    end
  end
end
