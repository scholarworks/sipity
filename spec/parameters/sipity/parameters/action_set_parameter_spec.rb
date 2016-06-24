require "rails_helper"
require 'sipity/parameters/action_set_parameter'

module Sipity
  module Parameters
    RSpec.describe ActionSetParameter do
      let(:identifier) { double }
      let(:collection) { double(any?: true, present?: true) }
      let(:entity) { double(processing_state: 'processing_state') }
      subject { described_class.new(identifier: identifier, collection: collection, entity: entity) }
      its(:identifier) { is_expected.to eq identifier }
      its(:collection) { is_expected.to eq [collection] }
      its(:processing_state) { is_expected.to eq entity.processing_state }
      its(:entity) { is_expected.to eq entity }
      its(:any?) { is_expected.to eq collection.any? }
      its(:present?) { is_expected.to eq collection.present? }
    end
  end
end
