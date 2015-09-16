require 'spec_helper'
require 'sipity/parameters/action_set_parameter'

module Sipity
  module Parameters
    RSpec.describe ActionSetParameter do
      let(:identifier) { double }
      let(:collection) { double(any?: true, present?: true) }
      let(:entity) { double(processing_state: 'processing_state') }
      subject { described_class.new(identifier: identifier, collection: collection, entity: entity) }
      its(:identifier) { should eq identifier }
      its(:collection) { should eq [collection] }
      its(:processing_state) { should eq entity.processing_state }
      its(:entity) { should eq entity }
      its(:any?) { should eq collection.any? }
      its(:present?) { should eq collection.present? }
    end
  end
end
